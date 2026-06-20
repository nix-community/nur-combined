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
    version = "2.38.5";

    src = pkgs.fetchFromGitHub {
      owner = "Vinzent03";
      repo = "obsidian-git";
      rev = version;
      sha256 = "sha256-CAgcpRmZxyUtfO0dqZN/79nSW6ge/a5qJCYJiHDkSGs=";
    };

    nativeBuildInputs = with pkgs; [
      nodejs
      pnpmConfigHook
      pnpm
    ];

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

    pnpmDeps = pkgs.fetchPnpmDeps {
      fetcherVersion = 3;
      inherit pname version src;
      hash =
        if isNewerVersion
        then "sha256-v9roDgzuElqrGm9UDsfvQ9mWUMI5Fe01kC1wMU1GlXk="
        else "sha256-ikzVERmBA0Hh31OgJEnWfnDK0ufxcu6MnR8Z241HFzo=";
    };

    meta = {
      description = "Integrate Git version control with automatic backup and other advanced features.";
      homepage = "https://github.com/Vinzent03/obsidian-git";
      changelog = "https://github.com/Vinzent03/obsidian-git/releases/tag/${version}";
      license = lib.licenses.mit;
    };
  }
