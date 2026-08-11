#! /usr/bin/env bash

# TODO use nix-shell shebang

# status: failed experiment. this did not work.
# simpler solution: pin maven-resources-plugin to version 2.6

#set -e # no. allow nix-build to fail
set -x

lockfile_path="pkgs/development/tools/mvn2nix/src/mvn2nix/mvn2nix-lock.json"

#previous_dependency_key=""

while true; do

nix_build_output=$(nix-build . -A mvn2nix 2>&1)
nix_build_output_path="nix-build-output-$(date +%s.%N).txt"
echo "$nix_build_output" >"$nix_build_output_path"

echo "parsing dependency_key's from nix_build_output"

dependency_key_list=()

dependency_key=$(echo "$nix_build_output" | grep "The following artifacts could not be resolved" | grep -v "^       > " | sed -E 's/^.* The following artifacts could not be resolved: ([^ ]+) .*$/\1/')
if [ -n "$dependency_key" ]; then
  echo "dependency_key: $dependency_key"
  dependency_key_list+=($dependency_key)
fi

while read warning_line; do
  dependency_key=$(echo "$warning_line" | sed -E 's/\[WARNING\] The POM for ([^ ]+) is missing, no dependency information available/\1/')
  echo "dependency_key: $dependency_key"
  dependency_key_list+=($dependency_key)
done < <(echo "$nix_build_output" | grep -E "^\[WARNING\] The POM for [^ ]+ is missing, no dependency information available")

# parse warnings
# example:
# [WARNING] The POM for org.codehaus.plexus:plexus-interpolation:jar:1.26 is missing, no dependency information available
# TODO

echo "adding dependency_key's to mvn2nix-lock.json"

dependencies_added=0

for dependency_key in "${dependency_key_list[@]}"; do

echo "dependency_key: $dependency_key"

if grep -q "\"$dependency_key\"" "$lockfile_path"; then
  echo "warning: dependency_key $dependency_key is already in lockfile $lockfile_path -> skip"
  continue
fi

if [[ "${#dependency_key_list[@]}" == "0" ]]; then
  echo "dependency_key_list is empty -> done"
  exit
fi

# TODO implement?
#if [[ "$dependency_key" == "$previous_dependency_key" ]]; then
#  echo "error: dependency_key was added in the previous iteration, but is still missing"
#  exit 1
#fi

dependency_domain=$(echo "$dependency_key" | sed -E 's/^([^:]+):.*$/\1/')
echo "dependency_domain: $dependency_domain"

dependency_name=$(echo "$dependency_key" | sed -E 's/^[^:]+:([^:]+):.*$/\1/')
echo "dependency_name: $dependency_name"

dependency_extension=$(echo "$dependency_key" | sed -E 's/^[^:]+:[^:]+:([^:]+):.*$/\1/')
echo "dependency_extension: $dependency_extension"

dependency_version=$(echo "$dependency_key" | sed -E 's/^.*:([^:]+)$/\1/')
echo "dependency_version: $dependency_version"

dependency_layout="$(echo "$dependency_domain" | tr . /)/$dependency_name/$dependency_version/$dependency_name-$dependency_version.$dependency_extension"
echo "dependency_layout: $dependency_layout"

dependency_url="https://repo.maven.apache.org/maven2/$dependency_layout"
echo "dependency_url: $dependency_url"

dependency_sha256=$(curl -s "$dependency_url" | sha256sum -)
dependency_sha256=${dependency_sha256:0:64}
echo "dependency_sha256: $dependency_sha256"

cat >mvn2nix-lock.json.fragment <<EOF
{
  "dependencies": {
    "$dependency_key": {
      "layout": "$dependency_layout",
      "sha256": "$dependency_sha256",
      "url": "$dependency_url"
    }
  }
}
EOF

# using jq for recursive merge of json objects
# https://stackoverflow.com/questions/19529688/how-to-merge-2-json-objects-from-2-files-using-jq
# jq -s '.[0] * .[1]' file1 file2
#lockfile_path="pkgs/development/tools/mvn2nix/src/mvn2nix/mvn2nix-lock.json"
backup_path="$lockfile_path".bak.$(date +%s.%N)
cp "$lockfile_path" "$backup_path"
jq -s '.[0] * .[1]' "$lockfile_path" mvn2nix-lock.json.fragment | sponge "$lockfile_path"
diff -u "$backup_path" "$lockfile_path"

#previous_dependency_key="$dependency_key"

dependencies_added=$((dependencies_added + 1))

done # for dependency_key

if [[ "$dependencies_added" == "0" ]]; then
  echo "no dependencies added -> done"
  exit
fi

done # while true
