{
  lib,
  pkgs,
  ...
}: let
  owner = "esm7";
  repo = "obsidian-vimrc-support";
in
  pkgs.buildNpmPackage rec {
    pname = "obsidian-vimrc-support";
    version = "0.10.2";

    src = pkgs.fetchFromGitHub {
      inherit owner repo;
      rev = version;
      sha256 = "sha256-q6QQ6Knh7WviccJJxPhxmyl63zPHjZvNcbAOVPbDwKc=";
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

    postPatch =
      # bash
      ''
        cp ${./package-lock.json} package-lock.json
      '';

    npmDepsHash = "sha256-P+/ZpMy0jiPI6SFQvgh+q0KR3pzqy76IwLXeTCpMFpY=";

    installPhase =
      # bash
      ''
        mkdir -p $out/
        cp main.js manifest.json $out/
      '';

    meta = {
      description = "Auto-load a startup file with Obsidian Vim commands.";
      homepage = "https://github.com/esm7/obsidian-vimrc-support";
      changelog = "https://github.com/esm7/obsidian-vimrc-support/releases/tag/${version}";
      license = lib.licenses.mit;
    };
  }
