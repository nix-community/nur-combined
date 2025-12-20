{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "obsidian-excalidraw-plugin";
  version = "2.18.2";

  src = pkgs.fetchFromGitHub {
    owner = "zsviczian";
    repo = "obsidian-excalidraw-plugin";
    rev = version;
    sha256 = "sha256-j11wPVy+HeklwxO54RZ3c7K4Dq+XdPf4P0KPXhAgRqQ=";
  };

  npmDepsHash = "sha256-+/yQgiyHa0X9XVvQyT4qbnh/LCPiJFCNkItgS+hBUzI=";

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
