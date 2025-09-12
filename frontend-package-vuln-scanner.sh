#!/bin/bash
set -e

# Clean workspace
rm -rf vuln-scan
npm create vite@latest vuln-scan -- --template react
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
          version: process.env.VERSION,
          name: v.name,
          current: pkg.dependencies[v.name] || "",
          severity: v.severity,
          fix: v.fixAvailable
            ? (v.fixAvailable.name
                ? v.fixAvailable.name + "@" + v.fixAvailable.version
                : v.fixAvailable.version)
            : null,
          major: v.fixAvailable && v.fixAvailable.isSemVerMajor
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

# Combine results
node -e "
const r1 = JSON.parse(\`$res1\`);
const r2 = JSON.parse(\`$res2\`);

const combined = {
  total: r1.total + r2.total,
  sev: { critical: 0, high: 0, moderate: 0, low: 0 },
  vulns: [...r1.vulns, ...r2.vulns]
};
['critical', 'high', 'moderate', 'low'].forEach(k => {
  combined.sev[k] = r1.sev[k] + r2.sev[k];
});

console.log('=== Combined Vulnerability Report ===');
console.log('Total vulnerable deps:', combined.total);

console.log('\\nBreakdown:');
for (const k of ['critical', 'high', 'moderate', 'low'])
  console.log('  ' + k.toUpperCase() + ':', combined.sev[k]);

if (combined.vulns.length > 0) {
  console.log('\\nVulnerable packages:');
  combined.vulns.forEach(v => {
    console.log(' - [' + v.version + '] ' + v.name + '@' + v.current + ' (' + v.severity + ')');
    if (v.fix) {
      console.log('    fix:', v.fix, v.major ? '(major)' : '');
    }
  });
} else {
  console.log('\\n✅ No vulnerabilities found across v1 and v2!');
}
"

# Clean up
cd ..
rm -rf vuln-scan