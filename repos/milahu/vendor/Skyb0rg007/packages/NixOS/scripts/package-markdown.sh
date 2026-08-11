#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash -p git -p jq -p nix
# shellcheck shell=bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: package-markdown.sh > FILE

Render Markdown documentation for the packages defined in this repository.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

script_dir=$(CDPATH="" cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(CDPATH="" cd -- "$script_dir/.." && pwd)
tracked_paths=$(mktemp)
trap 'rm -f "$tracked_paths"' EXIT

git -C "$repo_root" ls-files -z | jq -Rs 'split("\u0000")[:-1]' > "$tracked_paths"

metadata_json=$(
  # shellcheck disable=SC2016
  PACKAGE_MARKDOWN_ROOT=$repo_root PACKAGE_MARKDOWN_TRACKED=$tracked_paths nix eval --impure --json --expr '
    let
      trackedPaths = builtins.fromJSON (builtins.readFile (builtins.getEnv "PACKAGE_MARKDOWN_TRACKED"));
      trackedSet = builtins.listToAttrs (builtins.map (path: {
        name = path;
        value = true;
      }) trackedPaths);

      hasPrefix = prefix: value:
        builtins.substring 0 (builtins.stringLength prefix) value == prefix;

      relativePath = path:
        let
          rootString = builtins.getEnv "PACKAGE_MARKDOWN_ROOT";
          pathString = toString path;
        in
        if pathString == rootString then
          ""
        else
          builtins.substring (builtins.stringLength rootString + 1) (builtins.stringLength pathString) pathString;

      sourceFilter = path: type:
        let
          rel = relativePath path;
        in
        rel == ""
        || builtins.hasAttr rel trackedSet
        || (type == "directory" && builtins.any (tracked: hasPrefix "${rel}/" tracked) trackedPaths);

      root = builtins.path {
        path = builtins.getEnv "PACKAGE_MARKDOWN_ROOT";
        filter = sourceFilter;
        name = "nixos-packages";
      };
      packages = import root { };

      isDerivation = value:
        builtins.isAttrs value && value ? type && value.type == "derivation";

      concatMapAttrs = f: attrs:
        builtins.concatLists (
          builtins.map (name: f name attrs.${name}) (builtins.attrNames attrs)
        );

      concatStringsSep = sep: strings:
        let
          go = remaining:
            if remaining == [ ] then
              ""
            else if builtins.tail remaining == [ ] then
              builtins.head remaining
            else
              "${builtins.head remaining}${sep}${go (builtins.tail remaining)}";
        in
        go strings;

      pathToString = path: concatStringsSep "." path;

      valueToString = value:
        if value == null then
          null
        else if builtins.isString value then
          value
        else if builtins.isInt value || builtins.isBool value then
          builtins.toString value
        else
          null;

      licenseToString = license:
        if license == null then
          null
        else if builtins.isList license then
          concatStringsSep ", " (builtins.filter (value: value != null) (builtins.map licenseToString license))
        else if builtins.isAttrs license then
          license.spdxId or license.shortName or license.fullName or license.name or null
        else
          valueToString license;

      homepageToString = homepage:
        if homepage == null then
          null
        else if builtins.isList homepage then
          concatStringsSep ", " (builtins.filter (value: value != null) (builtins.map homepageToString homepage))
        else
          valueToString homepage;

      packageInfo = attrPath: package:
        let
          meta = package.meta or { };
        in
        {
          attrPath = pathToString attrPath;
          name = package.name or null;
          pname = package.pname or null;
          version = package.version or null;
          description = meta.description or null;
          homepage = homepageToString (meta.homepage or null);
          license = licenseToString (meta.license or null);
          mainProgram = meta.mainProgram or null;
          broken = meta.broken or false;
        };

      collect = attrPath: value:
        if isDerivation value then
          [ (packageInfo attrPath value) ]
        else if builtins.isAttrs value && (attrPath == [ ] || value.recurseForDerivations or false) then
          concatMapAttrs (name: collect (attrPath ++ [ name ])) value
        else
          [ ];

      lessThan = left: right: left.attrPath < right.attrPath;
    in
    builtins.sort lessThan (collect [ ] packages)
  '
)

render_markdown() {
  jq -r '
    def present: . != null and . != "";
    def dedupe_key:
      [
        .pname,
        .version,
        .description,
        .homepage,
        .license,
        .mainProgram
      ] | map(if . == null then "" else tostring end) | join("\u0000");
    def attr_preference:
      if .attrPath | test("^python3Packages\\.") then
        0
      elif .attrPath | test("^python[0-9]+Packages\\.") then
        1
      elif .attrPath | test("^tcl[0-9]+Packages\\.") then
        1
      else
        0
      end;
    def dedupe:
      sort_by(dedupe_key, attr_preference, .attrPath)
      | group_by(dedupe_key)
      | map(.[0])
      | sort_by(.attrPath);
    def escape_md:
      tostring
      | gsub("\\\\"; "\\\\\\\\")
      | gsub("\\*"; "\\*")
      | gsub("_"; "\\_")
      | gsub("`"; "\\`");
    def field($label; $value):
      select($value | present) | "- **\($label):** \($value | escape_md)";
    def homepage:
      if .homepage | present then
        if (.homepage | test("^https?://")) then
          "- **Homepage:** [\(.homepage | escape_md)](\(.homepage))"
        else
          field("Homepage"; .homepage)
        end
      else
        empty
      end;
    def package_entry:
      "## `" + .attrPath + "`",
      "",
      field("Package name"; .pname),
      field("Version"; .version),
      field("Description"; .description),
      homepage,
      field("License"; .license),
      (if .broken == true then "- **Status:** Broken" else empty end),
      "";

    dedupe
    | {
      packages: map(select(.broken != true)),
      broken: map(select(.broken == true))
    }
    |
    "# Packages",
    "",
    ("Generated from " + ((.packages | length) + (.broken | length) | tostring) + " packages."),
    "",
    (.packages[] | package_entry),
    (if (.broken | length) > 0 then
      "# Broken Packages",
      "",
      (.broken[] | package_entry)
    else
      empty
    end)
  ' <<<"$metadata_json"
}

render_markdown
