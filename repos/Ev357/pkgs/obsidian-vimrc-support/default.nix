{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "obsidian-vimrc-support";
  version = "0.10.2";

  src = pkgs.fetchFromGitHub {
    owner = "esm7";
    repo = "obsidian-vimrc-support";
    rev = version;
    sha256 = "sha256-q6QQ6Knh7WviccJJxPhxmyl63zPHjZvNcbAOVPbDwKc=";
  };

  postPatch =
    # bash
    ''
      cp ${./package-lock.json} package-lock.json
    '';

  npmDepsHash = "sha256-P+/ZpMy0jiPI6SFQvgh+q0KR3pzqy76IwLXeTCpMFpY=";

  installPhase =
    # bash
    ''
      mkdir -p $out/
      cp main.js manifest.json $out/
    '';

  meta = {
    description = "Auto-load a startup file with Obsidian Vim commands.";
    homepage = "https://github.com/esm7/obsidian-vimrc-support";
    changelog = "https://github.com/esm7/obsidian-vimrc-support/releases/tag/${version}";
    license = lib.licenses.mit;
  };
}
