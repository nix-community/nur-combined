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
    version = "1.6.2";

    src = pkgs.fetchFromGitHub {
      inherit owner repo;
      rev = version;
      sha256 = "sha256-YFKzLcMmXip3PqZN9+TwW8k6hqY6nc3XFGf1QTBdzsg=";
    };

    npmDepsHash = "sha256-MH7dZMs5qjCPMPe2QM2akbDgwN74vwVGGsA8PgVH1wA=";

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
