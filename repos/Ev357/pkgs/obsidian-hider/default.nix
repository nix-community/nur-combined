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
    version = "1.7.1";

    src = pkgs.fetchFromGitHub {
      inherit owner repo;
      rev = version;
      sha256 = "sha256-1llq4TPpI/mUIZAyyUSETq4WgUL0uSDO8Nrfx2aWyIE=";
    };

    npmDepsHash = "sha256-TEIR0hMvk3p5cAlBJ4B8kxbCjhjMHz5tP03X0vKpPMc=";

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
