{ writeShellScript, lib, curl, jq }:

writeShellScript "update-wemeet" ''
  set -e

  export PATH="${lib.makeBinPath [curl jq]}:$PATH"

  pushd pkgs/wemeet

  source <(curl --location https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=wemeet-bin)

  echo "''${source_x86_64[0]}"
  source_pattern="^[^:]+::(.+)$"
  [[ "''${source_x86_64[0]}" =~ $source_pattern ]]
  url_x86_64="''${BASH_REMATCH[1]}"
  [[ "''${source_aarch64[0]}" =~ $source_pattern ]]
  url_aarch64="''${BASH_REMATCH[1]}"

  jq --null-input \
    --arg version_x86_64 "$pkgver" \
    --arg url_x86_64 "$url_x86_64" \
    --arg sha512sum_x86_64 "''${sha512sums_x86_64[0]}" \
    --arg version_aarch64 "$pkgver" \
    --arg url_aarch64 "$url_aarch64" \
    --arg sha512sum_aarch64 "''${sha512sums_aarch64[0]}" \
    '{
      "x86_64-linux": {
        version: $version_x86_64,
        url: $url_x86_64,
        sha512: $sha512sum_x86_64
      },
      "aarch64-linux": {
        version: $version_aarch64,
        url: $url_aarch64,
        sha512: $sha512sum_aarch64
      }
    }' > source.json

  popd
''
