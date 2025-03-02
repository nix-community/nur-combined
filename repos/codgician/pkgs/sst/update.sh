#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

nur="$(git rev-parse --show-toplevel)"
path="$nur/pkgs/sst/default.nix"

url="https://www.solidigm.com/support-page/drivers-downloads/ka-00085.html"
page_content=$(curl -sL "$url")

# Check if curl was successful.
if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve the webpage." >&2
  exit 1
fi

# Extract first matching file name
filename=$(echo "$page_content" | grep -oPm 1 'sst-cli-linux-deb--([0-9]+-[0-9]+)\.zip')
if [ -z "$filename" ]; then
  echo "Error: No matching filename found on the webpage." >&2
  exit 1
fi

# Extract version
version_dash=$(echo "$filename" | grep -oP '(?<=sst-cli-linux-deb--)[\d-]+(?=\.zip)')
version=$(echo "$version_dash" | sed 's/-/./g')

# Skip updating if current version is not older
old_version="$(nix-instantiate --eval -E "with import ./. {}; lib.getVersion sst" | tr -d '"')"
if [[ "$old_version" > "$version" || "$old_version" == "$version" ]]; then
    echo "Current version $old_version is up-to-date"
    exit 0
fi

# Update nix file
zip_url="https://sdmsdfwdriver.blob.core.windows.net/files/kba-gcc/drivers-downloads/ka-00085/sst--${version_dash}/sst-cli-linux-deb--${version_dash}.zip";
sha256="$(nix store prefetch-file $zip_url --json | jq -r '.hash')"
sed -i -e "s,version = \"$old_version\",version = \"$version\"," \
    -e "s,hash = \"sha256-.*\",hash = \"$sha256\"," "$path"

echo "Updated sct $old_version -> $version"
