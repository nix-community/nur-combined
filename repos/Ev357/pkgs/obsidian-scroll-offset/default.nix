{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "obsidian-scroll-offset";
  version = "1.0.7";

  src = pkgs.fetchFromGitHub {
    owner = "lijyze";
    repo = "scroll-offset";
    rev = version;
    sha256 = "sha256-DGDpT71n8Ke5+hMbV/AN/d+UIq+Nss0WXVXdyq9WXI8=";
  };

  npmDepsHash = "sha256-vA56+BgK02iiDnGqgDggHxS/TafwzbYhxekwzkwBxDc=";

  installPhase =
    # bash
    ''
      mkdir -p $out/
      cp main.js manifest.json $out/
    '';

  meta = {
    description = "Preserve minmium distances before and after cursor.";
    homepage = "https://github.com/lijyze/scroll-offset";
    changelog = "https://github.com/lijyze/scroll-offset/releases/tag/${version}";
    license = lib.licenses.mit;
  };
}
