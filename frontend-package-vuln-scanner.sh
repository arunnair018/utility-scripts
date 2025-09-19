#!/bin/bash

# Install Node.js v16 using nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 16
node -v
npm -v

# Exit on error
set -e

# Clean workspace
rm -rf vuln-scan

# Create a temporary Vite React project
npm create vite@4 vuln-scan -- --template react
cd vuln-scan

# Function to scan a version
run_scan() {
  local version=$1
  local pkgPath=$2

  # Prepare package.json from given path
  PKG_PATH="$pkgPath" VERSION="$version" node -e '
    const fs = require("fs");
    const path = require("path");
    const pkgPath = path.resolve(process.env.PKG_PATH);
    const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
    delete pkg.devDependencies;
    fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2));
  '

  # Create lock file
  npm install --package-lock-only --legacy-peer-deps --silent

  # Run audit and filter only direct deps
  (npm audit --json || true) | VERSION="$version" node -e '
    const fs = require("fs");
    const pkg = require("./package.json");
    const directDeps = new Set(Object.keys(pkg.dependencies || {}));
    try {
      const audit = JSON.parse(fs.readFileSync(0, "utf8"));
      const vulns = Object.values(audit.vulnerabilities || {});
      let directVulns = vulns.filter(v => !!v.isDirect);
      directVulns = directVulns.filter(v => {
        if (typeof v.via === "string") {
          return v.via === v.name;
        }
        return v.via.some(via => typeof via === "string" ? via === v.name : via.name === v.name);
      });
      const out = {
        total: directVulns.length,
        sev: { critical: 0, high: 0, moderate: 0, low: 0 },
        vulns: []
      };

      directVulns.forEach(v => {
        out.sev[v.severity]++;
        out.vulns.push({
          name: v.name,
          current: pkg.dependencies[v.name] || "",
          severity: v.severity,
          fix: v.fixAvailable
            ? (v.fixAvailable.name
                ? v.fixAvailable.name + "@" + v.fixAvailable.version
                : v.fixAvailable.version)
            : null,
        });
      });

      console.log(JSON.stringify(out));
    } catch (e) {
      console.error("Error:", e.message);
      console.log(JSON.stringify({ total: 0, sev: { critical: 0, high: 0, moderate: 0, low: 0 }, vulns: [] }));
    }
  '
}

# Collect results
res1=$(run_scan "v1" "../web-package/node1/package.json")
res2=$(run_scan "v2" "../web-package/node2/package.json")
echo "Scan results collected."
echo "Node1 Result: $res1"
echo "Node2 Result: $res2"

# Combine results
combined_result=$(node -e "
const r1 = JSON.parse(\`$res1\`);
const r2 = JSON.parse(\`$res2\`);
const combined = {
  timestamp : new Date().toISOString(),
  total: r1.total + r2.total,
  sev: { critical: 0, high: 0, moderate: 0, low: 0 },
  vulns: [...r1.vulns, ...r2.vulns]
};
['critical', 'high', 'moderate', 'low'].forEach(k => {
  combined.sev[k] = r1.sev[k] + r2.sev[k];
});
console.log(JSON.stringify(combined));
")

# Format final result
formatted_result=$(node -e '
const combined = JSON.parse(`'"$combined_result"'`);
const finalReport = {
  scanner: {
    name: "fe-package-vuln-scan",
    engine: "npm-audit",
    ruleset: "npm-audit-default"
  },
  summary: {
    total_vulnerabilities: combined.total,
    severity: {
      critical: combined.sev.critical,
      high: combined.sev.high,
      moderate: combined.sev.moderate,
      low: combined.sev.low
    }
  },
  vulnerabilities: combined.vulns,
  generated_at: combined.timestamp
};
console.log(JSON.stringify(finalReport, null, 2));
')

# Prepare Slack message (multiline JSON code block)
SLK_MSG=":male-factory-worker: <!subteam^SEJN6TVNE>
*Frontend Package Vulnerability Scan Report:*
\`\`\`
$formatted_result
\`\`\`"

# Escape it properly so Slack accepts it
escaped_msg=$(node -e "console.log(JSON.stringify(process.argv[1]))" "$SLK_MSG")

# Send to Slack
curl -X POST -H 'Content-type: application/json' \
--data '{"text": '"$escaped_msg"'}' \
$SLACK_DEVELOPMENT_WEBHOOK

echo "Formatted Result: $escaped_msg"

# Clean up
cd ..
rm -rf vuln-scan
