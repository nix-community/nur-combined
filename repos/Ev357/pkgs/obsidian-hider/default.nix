{
  lib,
  pkgs,
  ...
}: let
  owner = "kepano";
  repo = "obsidian-hider";
in
  pkgs.buildNpmPackage rec {
    pname = "obsidian-hider";
    version = "1.6.1";

    src = pkgs.fetchFromGitHub {
      inherit owner repo;
      rev = version;
      sha256 = "sha256-wOq3VuIwZeBWh+oq8gUYGYWtBJc0b1uE0RjbnTcieRc=";
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

    npmDepsHash = "sha256-4LVgsQV8ovszOfn/3lreyDPZpnlnsxAD//uPBzUkhRI=";

    postPatch =
      # bash
      ''
        cp ${./package-lock.json} package-lock.json
      '';

    installPhase =
      # bash
      ''
        mkdir -p $out/
        cp main.js manifest.json styles.css $out/
      '';

    meta = {
      description = "Hide UI elements such as tooltips, status, titlebar and more";
      homepage = "https://github.com/kepano/obsidian-hider";
      changelog = "https://github.com/kepano/obsidian-hider/releases/tag/${version}";
      license = lib.licenses.mit;
    };
  }
