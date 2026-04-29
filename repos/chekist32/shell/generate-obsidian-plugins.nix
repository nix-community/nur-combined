{ pkgs }:
pkgs.writeShellScriptBin "generate-obsidian-plugins" ''
  set -e
  JQ="${pkgs.jq}/bin/jq"
  CURL="${pkgs.curl}/bin/curl"

  prefetch() {
    ${pkgs.nix}/bin/nix store prefetch-file "$1" --json 2>/dev/null | $JQ -r '.hash // empty'
  }

  [[ -z "$1" ]] && echo "Usage: $0 <plugins.json>" >&2 && exit 1

  echo "{ mkObsidianPlugin }: {"
  $JQ -c '.[]' "$1" | while read -r P; do
    REPO=$($JQ -r '.repo' <<< "$P")
    VERSION=$($JQ -r '.version' <<< "$P")
    BASE="$REPO/releases/download/$VERSION"
    MANIFEST=$($CURL -sL "$BASE/manifest.json")
    NAME=$(echo "$MANIFEST" | $JQ -r '.id')
    DESC=$(echo "$MANIFEST" | $JQ -r '.description // ""')
    MAIN_HASH=$(prefetch "$BASE/main.js")
    MANIFEST_HASH=$(prefetch "$BASE/manifest.json")
    STYLES_HASH=$(prefetch "$BASE/styles.css" || true)

    cat <<EOF
    $NAME = mkObsidianPlugin {
      name = "$NAME";
      version = "$VERSION";
      repo = "$REPO";
      mainJsSha256 = "$MAIN_HASH";
      manifestSha256 = "$MANIFEST_HASH";
      $([ -n "$STYLES_HASH" ] && echo "stylesCssSha256 = \"$STYLES_HASH\";")
      description = "$DESC";
    };
  EOF
  done
  echo "}"
''
