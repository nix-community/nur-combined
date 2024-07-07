#! /usr/bin/env nix-shell
#! nix-shell --pure -i bash -p nodejs_latest nodePackages.node2nix wget python3

wget --no-check-certificate https://github.com/SCOTT-HAMILTON/tfk-api-unoconv/raw/master/package.json

code=$(cat << EOF
import json

package_json = json.load(open('package.json', 'r'))
devDeps = package_json["devDependencies"] \
	if "devDependencies" in package_json.keys() else {}
package_json["dependencies"].update(devDeps)
if devDeps != {}:
	del package_json["devDependencies"]
with open("package.json", "w+") as file:
    file.write(json.dumps(package_json, indent = 2))
EOF
)
python -c "$code"
npm install
rm -rf node_modules
mv default.nix default.nix.save
node2nix --nodejs-16 -l package-lock.json
rm default.nix
mv default.nix.save default.nix

sed -i '/src = \.\/\.;/d' node-packages.nix
sed -i '/args = {/a \ \ \ \ inherit src;' node-packages.nix
sed -Ei 's=, globalBuildInputs.*=, globalBuildInputs ? [], src\}:=g' node-packages.nix

rm package.json
