{
  writeShellScript,
  lib,
  curl,
  jq,
}:

writeShellScript "update-wemeet" ''
  set -e

  export PATH="${
    lib.makeBinPath [
      curl
      jq
    ]
  }:$PATH"

  while [[ $# -gt 0 ]]; do
    case $1 in
      --write-commit-message)
        commit_message_file="$2"
        shift 2
        ;;
      *)
        echo "unknown option $1" 1>&2
        exit 1
        ;;
    esac
  done

  pushd pkgs/wemeet

  version_old_x86_64=$(jq --raw-output '."x86_64-linux".version' source.json)
  version_old_aarch64=$(jq --raw-output '."aarch64-linux".version' source.json)

  source <(curl --location https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=wemeet-bin)

  version_x86_64="$pkgver"
  version_aarch64="$_pkgver_arm"

  echo "''${source_x86_64[0]}"
  source_pattern="^[^:]+::(.+)$"
  [[ "''${source_x86_64[0]}" =~ $source_pattern ]]
  url_x86_64="''${BASH_REMATCH[1]}"
  [[ "''${source_aarch64[0]}" =~ $source_pattern ]]
  url_aarch64="''${BASH_REMATCH[1]}"

  jq --null-input \
    --arg version_x86_64 "$version_x86_64" \
    --arg url_x86_64 "$url_x86_64" \
    --arg sha512sum_x86_64 "''${sha512sums_x86_64[0]}" \
    --arg version_aarch64 "$version_aarch64" \
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

    if [[ -n "$commit_message_file" ]]; then
      if [[ -f "$commit_message_file" ]]; then
        rm "$commit_message_file"
      fi

      if [[ "$version_x86_64" != "$version_old_x86_64" ]]; then
        echo "wemeet (x86_64-linux): $version_old_x86_64 -> $version_x86_64" >> "$commit_message_file"
      fi

      if [[ "$version_aarch64" != "$version_old_aarch64" ]]; then
        echo "wemeet (aarch64-linux): $version_old_aarch64 -> $version_aarch64" >> "$commit_message_file"
      fi
    fi

  popd
''
