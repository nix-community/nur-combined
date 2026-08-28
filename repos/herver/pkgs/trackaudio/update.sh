#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep jq nix

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
attr=trackaudio
nix_file="$dirname/default.nix"

currentVersion=$(grep 'version = ' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

# Pick the newest release by SemVer precedence, so a stable outranks its own
# prereleases (1.4.0 > 1.4.0-beta.10). GitHub's list order and its prerelease
# flag are both unreliable for this repo, so we rank the tags ourselves.
# Prints "UPTODATE" when nothing outranks the pinned version (never downgrades).
latestVersion=$(curl -s 'https://api.github.com/repos/pierr3/TrackAudio/releases?per_page=100' \
  | jq -r --arg current "$currentVersion" '
      def semverkey:
        sub("\\+.*$"; "") as $v
        | ($v | split("-")) as $parts
        | ($parts[0] | split(".") | map(tonumber)) as $core
        | ($parts[1:] | if length==0 then null else (join("-") | split(".")) end) as $pre
        | $core
          + [ (if $pre==null then 1 else 0 end) ]
          + [ (if $pre==null then [] else ($pre | map(if test("^[0-9]+$") then tonumber else . end)) end) ];
      ([ .[] | select(.draft==false) | .tag_name | sub("^v";"")
          | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+")) ]) as $tags
      | if ($tags | length) == 0 then "ERROR"
        else ($tags | map({v:., k:semverkey}) | max_by(.k)) as $best
          | if ($best.k) > ($current | semverkey) then $best.v else "UPTODATE" end
        end')

if [ -z "$latestVersion" ] || [ "$latestVersion" = "null" ] || [ "$latestVersion" = "ERROR" ]; then
  echo "$attr: failed to fetch latest version from GitHub" >&2
  exit 1
fi

if [ "$latestVersion" = "UPTODATE" ]; then
  echo "$attr is up-to-date: ${currentVersion}"
  exit 0
fi

echo "$attr: $currentVersion -> $latestVersion"

# Download the .deb asset and compute its SRI hash.
url="https://github.com/pierr3/TrackAudio/releases/download/${latestVersion}/trackaudio_${latestVersion}_amd64.deb"
hash=$(nix-prefetch-url "$url" --type sha256)
sriHash=$(nix hash convert --hash-algo sha256 --to sri "$hash")

# Update version and hash in default.nix
sed -E \
  -e "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" \
  -e "s|hash = \"sha256-[a-zA-Z0-9/+=]+\";|hash = \"$sriHash\";|" \
  -i "$nix_file"

echo "Updated $nix_file"
