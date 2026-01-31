{
  lib,
  pkgs,
  ...
}: let
  owner = "nadavspi";
  repo = "obsidian-relative-line-numbers";
in
  pkgs.buildNpmPackage rec {
    pname = "obsidian-relative-line-numbers";
    version = "3.1.0";

    src = pkgs.fetchFromGitHub {
      inherit owner repo;
      rev = version;
      sha256 = "sha256-ZBfBWmAIuaJlD4VKLn/2k0jWtzI5j+ewsSzpjJaCnAY=";
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

    npmDepsHash = "sha256-asv7sRJi7kjsyHhXbdxrTD+KnxRhhEUSOVT8CmGcOg8=";

    installPhase =
      # bash
      ''
        mkdir -p $out/
        cp main.js manifest.json styles.css $out/
      '';

    meta = {
      description = "Enables relative line numbers in editor mode";
      homepage = "https://github.com/nadavspi/obsidian-relative-line-numbers";
      changelog = "https://github.com/nadavspi/obsidian-relative-line-numbers/releases/tag/${version}";
      license = lib.licenses.free;
    };
  }
