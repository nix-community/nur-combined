{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "obsidian-excalidraw-plugin";
  version = "2.19.2";

  src = pkgs.fetchFromGitHub {
    owner = "zsviczian";
    repo = "obsidian-excalidraw-plugin";
    rev = version;
    sha256 = "sha256-96J56ryarp5ZoVZR+URPxD/0Ns6znb0wdRWeO6wgnRU=";
  };

  npmDepsHash = "sha256-T3JVhsNOPTCL6cl4nNRFocoPHXLQaOlV3UdZlaNmB3k=";

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
