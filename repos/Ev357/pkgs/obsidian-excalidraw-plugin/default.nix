{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "obsidian-excalidraw-plugin";
  version = "2.15.3";

  src = pkgs.fetchFromGitHub {
    owner = "zsviczian";
    repo = "obsidian-excalidraw-plugin";
    rev = version;
    sha256 = "sha256-r5L+QWwVfx0j2z/dB86+uZSETFeApCscgWoappiRulw=";
  };

  npmDepsHash = "sha256-SmAh2S4eGZKY5QtP1HxISdHJ2xnSFVtZwfIMKwSPiaY=";

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
