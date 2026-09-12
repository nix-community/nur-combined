package_file="$1"

read -r tag asset url < <(
  curl -fsSL https://api.github.com/repos/RPCS3/rpcs3-binaries-linux/releases/latest |
    jq -r '
      .tag_name as $tag
      | .assets[]
      | select(.name | endswith("_linux64.AppImage"))
      | [$tag, .name, .browser_download_url]
      | @tsv
    '
)

commit="${tag#build-}"
short_commit="${commit:0:8}"

version="${asset#rpcs3-v}"
version="${version%-"$short_commit"_linux64.AppImage}"

hash="$(
  nix store prefetch-file --json "$url" |
    jq -r .hash
)"

VERSION="$version" \
COMMIT="$commit" \
SHORT_COMMIT="$short_commit" \
HASH="$hash" \
perl -0pi -e '
  s{version = "[^"]+";}{version = "$ENV{VERSION}";};
  s{commit = "[^"]+";}{commit = "$ENV{COMMIT}";};
  s{shortCommit = "[^"]+";}{shortCommit = "$ENV{SHORT_COMMIT}";};
  s{hash = "[^"]+";}{hash = "$ENV{HASH}";};
' "$package_file"
