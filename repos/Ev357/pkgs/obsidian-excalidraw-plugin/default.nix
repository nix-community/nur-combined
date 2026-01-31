{
  lib,
  pkgs,
  ...
}: let
  owner = "zsviczian";
  repo = "obsidian-excalidraw-plugin";
in
  pkgs.buildNpmPackage rec {
    pname = "obsidian-excalidraw-plugin";
    version = "2.19.2";

    src = pkgs.fetchFromGitHub {
      inherit owner repo;
      rev = version;
      sha256 = "sha256-96J56ryarp5ZoVZR+URPxD/0Ns6znb0wdRWeO6wgnRU=";
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
        popd > /dev/null
        cp "$WORKDIR/package-lock.json" pkgs/${pname}/

        nix-update ${pname} --flake
      '';

    npmDepsHash = "sha256-T3JVhsNOPTCL6cl4nNRFocoPHXLQaOlV3UdZlaNmB3k=";

    postPatch =
      # bash
      ''
        cp ${./package-lock.json} package-lock.json
      '';

    npmBuildScript = "build:all";

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
