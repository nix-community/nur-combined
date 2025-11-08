{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "obsidian-excalidraw-plugin";
  version = "2.17.0";

  src = pkgs.fetchFromGitHub {
    owner = "zsviczian";
    repo = "obsidian-excalidraw-plugin";
    rev = version;
    sha256 = "sha256-/8vvIuPO9DNahTdn7nyC2PCeGqCo/f5GzLJHo38x3mk=";
  };

  npmDepsHash = "sha256-npAYX/fdi/0g/b/+D3IfPhTLYVk4Kx6msbCobxi31v0=";

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
