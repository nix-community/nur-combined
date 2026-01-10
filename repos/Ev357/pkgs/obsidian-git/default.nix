{
  stdenv,
  lib,
  pkgs,
  ...
}: let
  isNewerVersion = lib.versionAtLeast lib.version "26.05pre";
in
  stdenv.mkDerivation rec {
    pname = "obsidian-git";
    version = "2.36.0";

    src = pkgs.fetchFromGitHub {
      owner = "Vinzent03";
      repo = "obsidian-git";
      rev = version;
      sha256 = "sha256-3r4nxIWx7j6j7V3kbHt1nJG7hBJazxzdDD4m8DbQoWw=";
    };

    nativeBuildInputs = with pkgs;
      [
        nodejs
      ]
      ++ (
        if isNewerVersion
        then [pnpmConfigHook pnpm]
        else [pnpm.configHook]
      );

    buildPhase =
      # bash
      ''
        runHook preBuild

        pnpm run build

        runHook postBuild
      '';

    installPhase =
      # bash
      ''
        mkdir -p $out/
        cp main.js manifest.json styles.css $out/
      '';

    pnpmDeps =
      (
        if isNewerVersion
        then pkgs.fetchPnpmDeps
        else pkgs.pnpm.fetchDeps
      ) {
        fetcherVersion = 2;
        inherit pname version src;
        hash = "sha256-pEWuqWLfqCYOfVNgiqayGUNAKC2VkfOfu7yXfqqhnl4=";
      };

    meta = {
      description = "Integrate Git version control with automatic backup and other advanced features.";
      homepage = "https://github.com/Vinzent03/obsidian-git";
      changelog = "https://github.com/Vinzent03/obsidian-git/releases/tag/${version}";
      license = lib.licenses.mit;
    };
  }
