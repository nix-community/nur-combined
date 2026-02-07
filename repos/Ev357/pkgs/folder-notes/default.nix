{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "folder-notes";
  version = "1.8.18";

  src = pkgs.fetchFromGitHub {
    owner = "LostPaul";
    repo = "obsidian-folder-notes";
    rev = version;
    sha256 = "sha256-dIwjeabJ4/EhAqgD+FhgGHTzj/uG1VDgkyX8FAoONTg=";
    fetchSubmodules = true;
  };

  npmDepsHash = "sha256-YASHi1cwZnqg40t6VLoWxHARtmSa5qwS8kCBVueHhv0=";

  postPatch =
    # bash
    ''
      cp ${./package-lock.json} package-lock.json
    '';

  npmBuildScript = "fn-build";

  installPhase =
    # bash
    ''
      mkdir -p $out/
      cp main.js styles.css $out/
      cp manifest-beta.json $out/manifest.json
    '';

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  meta = {
    description = "Create notes within folders that can be accessed without collapsing the folder, similar to the functionality offered in Notion.";
    homepage = "https://lostpaul.github.io/obsidian-folder-notes";
    changelog = "https://github.com/LostPaul/obsidian-folder-notes/releases/tag/${version}";
    license = lib.licenses.agpl3Only;
  };
}
