{
  lib,
  pkgs,
  enableHiddenScriptPatch ? false,
  ...
}: let
  owner = "zsviczian";
  repo = "obsidian-excalidraw-plugin";
in
  pkgs.buildNpmPackage rec {
    pname = "obsidian-excalidraw-plugin";
    version = "2.23.7";

    src = pkgs.fetchFromGitHub {
      inherit owner repo;
      rev = version;
      sha256 = "sha256-n51/POxIfu0yJ2QMNiI+AhxosOfQCxYjYRgjk6oVnoE=";
    };

    passthru.updateScript =
      pkgs.writeScript "update-${pname}"
      # bash
      ''
        #!/usr/bin/env nix-shell
        #!nix-shell -i bash -p curl jq git nodejs nix-update

        set -eu -o pipefail

        TAG="$(curl -s "https://api.github.com/repos/${owner}/${repo}/releases/latest" | jq -r .tag_name)"

        WORKDIR=$(mktemp -d)

        git clone --quiet --config advice.detachedHead=false --depth 1 --branch "$TAG" "https://github.com/${owner}/${repo}" "$WORKDIR"
        pushd "$WORKDIR" > /dev/null
        npm install --package-lock-only --ignore-scripts

        sed -i 's/\r$//' package-lock.json

        popd > /dev/null
        cp "$WORKDIR/package-lock.json" pkgs/${pname}/

        nix-update ${pname} --flake
      '';

    npmDepsHash = "sha256-7OTdQ+2zUOPFLrXInrrWfDtuGZ/5E9yEPcx8KzZan5w=";

    patches =
      [
        ./npm-install.patch
      ]
      ++ lib.optional enableHiddenScriptPatch ./hidden-script.patch;

    postPatch =
      # bash
      ''
        cp ${./package-lock.json} package-lock.json
      '';

    installPhase =
      # bash
      ''
        mkdir -p $out/
        cp dist/main.js dist/manifest.json dist/styles.css $out/
      '';

    meta = {
      description = "An Obsidian plugin to edit and view Excalidraw drawings";
      homepage = "https://excalidraw-obsidian.online";
      changelog = "https://github.com/zsviczian/obsidian-excalidraw-plugin/releases/tag/${version}";
      license = lib.licenses.mit;
    };
  }
