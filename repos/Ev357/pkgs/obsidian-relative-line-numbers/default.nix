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
