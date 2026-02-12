#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

nur="$(git rev-parse --show-toplevel)"
path="$nur/pkgs/cvm-agent/default.nix"
url="https://cloud-monitor-1258344699.cos.ap-guangzhou.myqcloud.com/sgagent/linux_stargate_installer"

# Download installer and compute hash
echo "Downloading installer..."
tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT
curl -sL -o "$tmpdir/linux_stargate_installer" "$url"
if [ $? -ne 0 ]; then
    echo "Error: Failed to download installer." >&2
    exit 1
fi

new_hash="$(nix hash file --type sha256 "$tmpdir/linux_stargate_installer")"

# Extract embedded tar and read version from base.conf
tail_num=$(sed -n '/^#real installing packages append below/{=;q;}' "$tmpdir/linux_stargate_installer")
tail_num=$((tail_num + 1))
tail -n +"$tail_num" "$tmpdir/linux_stargate_installer" > "$tmpdir/package.tgz"
tar -xzf "$tmpdir/package.tgz" -C "$tmpdir" stargate.tgz
tar -xzf "$tmpdir/stargate.tgz" -C "$tmpdir" stargate/etc/base.conf
upstream_version=$(sed -n 's/^version\s*=\s*//p' "$tmpdir/stargate/etc/base.conf" | tr -d '[:space:]')

if [ -z "$upstream_version" ]; then
    echo "Error: Failed to extract version from base.conf." >&2
    exit 1
fi

new_version="${upstream_version}"

# Compare with current
old_hash="$(sed -nE 's/\s*hash = "(.*)".*/\1/p' "$path")"
old_version="$(sed -nE 's/\s*version = "(.*)".*/\1/p' "$path")"

if [[ "$new_hash" == "$old_hash" ]]; then
    echo "Current hash is up-to-date (version: $old_version)."
    exit 0
fi

# Update nix file
sed -i -e "s,version = \"$old_version\",version = \"$new_version\"," \
    -e "s,hash = \"$old_hash\",hash = \"$new_hash\"," "$path"

echo "Updated cvm-agent $old_version -> $new_version (hash changed)"
