# nix run -f pkgs/public/base16/update.nix base16-update -c base16-update
{ pkgs ? import <nixpkgs> { } }: with pkgs; with lib; let
  sourcesRepo = toString ./sources-working;
  sourcesGit = "git -C ${sourcesRepo}";
  default = import ./default.nix;
  sourceRepos = {
    base16-templates-source = {
      output = toString ./templates.json;
      package = pkgs.callPackage default.base16-templates-source { };
    };
    base16-schemes-source = {
      output = toString ./schemes.json;
      package = pkgs.callPackage default.base16-schemes-source { };
    };
  };
  parseRepo = repoUrl: let
    type =
      if hasPrefix "https://github.com/" repoUrl then "github"
      else if hasPrefix "https://gitlab.com/" repoUrl then "gitlab"
      else if hasPrefix "https://git.sr.ht/" repoUrl then "sourcehut"
      else throw "Unknown repo URL for ${repoUrl}";
    pattern = {
      github = ''https://github\.com/([^/]+)/(.+)'';
      gitlab = ''https://gitlab\.com/([^/]+)/(.+)'';
      sourcehut = ''https://git\.sr\.ht/~([^/]+)/(.+)'';
    }.${type};
    matches = builtins.match pattern repoUrl;
    owner = elemAt matches 0;
    repo = elemAt matches 1;
  in if matches == null then throw ''Failed to parse "${repoUrl}"'' else {
    inherit type owner repo;
  };
  updateSource = key: source: let
    sources = importJSON "${source.package}/list.yaml";
    isScheme = key == "base16-schemes-source";
    mapSource = key: repoUrl: let
      repo = parseRepo repoUrl;
    in ''
      echo "updating ${key}" >&2
      timeout 30 ${sourcesGit} fetch --force -q ${repoUrl} :source-${key}
      SOURCE_REV=$(${sourcesGit} show-ref -s source-${key})
      SOURCE_DATE=$(${sourcesGit} show -s --format=%cs source-${key})
      SOURCE_CHECKOUT=$(mktemp -d --tmpdir tmp.nixexprs.XXXXXXXX)
      ${sourcesGit} checkout -qf --detach source-${key}
      cp -a ${sourcesRepo} "$SOURCE_CHECKOUT/source"
      rm -rf "$SOURCE_CHECKOUT/source/.git"
      SOURCE_HASH=$(nix-hash --base32 --type sha256 "$SOURCE_CHECKOUT/source")
      TEMPLATE_CONFIG="$SOURCE_CHECKOUT/source/templates/config.yaml"
      if [[ -n "${toString isScheme}" ]]; then
        SCHEME_NAMES=()
        for schemefile in $(cd "$SOURCE_CHECKOUT/source" && echo *.yaml *.yml); do
          SCHEME_NAMES+=("''${schemefile%.*}")
        done
      else
        SOURCE_CONFIG="$(${yq}/bin/yq -c . "$TEMPLATE_CONFIG")"
        EXTRA_CONFIG=()
        for templatefile in $(cd "$SOURCE_CHECKOUT/source" && echo templates/*.mustache); do
          templatefile=$(basename "$templatefile")
          templatefile="''${templatefile%.*}"
          if ! yq -e "has(\"$templatefile\")" "$TEMPLATE_CONFIG" > /dev/null; then
            echo "$templatefile.mustache does not have an associated config entry" >&2
            EXTRA_CONFIG+=("$templatefile")
            SOURCE_CONFIG="$(echo "$SOURCE_CONFIG" | ${jq}/bin/jq -c ". + { \"$templatefile\": {} }")"
          fi
        done
      fi
      rm -r "$SOURCE_CHECKOUT"
      if [[ -n $FIRST ]]; then
        printf , >> ${source.output}
      fi
      FIRST=1

      printf '"%s": { "type": "%s", "rev": "%s", "version": "%s", "owner": "%s", "repo": "%s", "sha256": "%s"' "${key}" "${repo.type}" "$SOURCE_REV" "$SOURCE_DATE" "${repo.owner}" "${repo.repo}" "$SOURCE_HASH" >> ${source.output}
      if [[ -n "${toString isScheme}" ]]; then
        if [[ ''${#SCHEME_NAMES[@]} -eq 1 && ''${SCHEME_NAMES[0]} = "${key}" ]]; then
          # as a shorthand, omit "schemes" if a single scheme exists with the same slug as the repo
          printf ' }\n' >> ${source.output}
        else
          SOURCE_FILES="$(jq -cnR '[inputs]' < <(for sname in ''${SCHEME_NAMES[@]+"''${SCHEME_NAMES[@]}"}; do echo "$sname"; done))"
          printf ', "schemes": %s }\n' "$SOURCE_FILES" >> ${source.output}
        fi
      else
        printf ', "config": %s }\n' "$SOURCE_CONFIG" >> ${source.output}
      fi
    '';
  in ''
    FIRST=
    echo "{" > ${source.output}
    ${concatStringsSep "\n" (mapAttrsToList mapSource sources)}
    echo "}" >> ${source.output}
  '';
in {
  base16-update = writeShellScriptBin "base16-update" ''
    set -eu
    shopt -s nullglob

    git init -q ${sourcesRepo}
    ${concatStringsSep "\n" (mapAttrsToList updateSource sourceRepos)}
  '';
} // mapAttrs (key: value: importJSON value.output) sourceRepos
