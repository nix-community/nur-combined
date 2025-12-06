{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "obsidian-excalidraw-plugin";
  version = "2.18.0";

  src = pkgs.fetchFromGitHub {
    owner = "zsviczian";
    repo = "obsidian-excalidraw-plugin";
    rev = version;
    sha256 = "sha256-4f8lUin3Cvo+7+Y06b0F7PcTbSOAAAGR5FYXqfLyVqA=";
  };

  npmDepsHash = "sha256-49j2ZHOCeolo8TRbnXk3GaFIThvj771LNn2LlslD0jQ=";

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
