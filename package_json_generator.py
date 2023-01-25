# input
#   - file containing versions [ text file containing output of `npm outdated` ]
#   - current package.json
new_version_file_path = 'new_versions.txt'
original_package_file_path = 'package.json'

# output
#   - new package json with updated versions
new_package_file_path = 'updated_package.json'

new_pacakages = []
new_versions = []
new_file_lines = []

def get_version (line):
    [package,current,wanted,latest,location] = line.split()
    return [package,latest]

with open(new_version_file_path) as file:
    for line in file:
        line = line.rstrip()
        if not len(line):
            continue
        [package,version] = get_version(line)
        new_pacakages.append(package)
        new_versions.append(version) 

with open(original_package_file_path) as file:
    for line in file:
        package_in_line = line.split(":")[0].strip().strip('"')
        if package_in_line in new_pacakages:
            index = new_pacakages.index(package_in_line)
            new_file_lines.append('\t\t"{}": "{}",'.format(new_pacakages[index],new_versions[index]))
            continue
        new_file_lines.append(line)
        
with open(new_package_file_path,'a') as file:
    for line in new_file_lines:
        file.write(line+'\n')