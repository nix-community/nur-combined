{
  lib,
  pkgs,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "obsidian-scroll-offset";
  version = "1.0.4";

  src = pkgs.fetchFromGitHub {
    owner = "lijyze";
    repo = "scroll-offset";
    rev = version;
    sha256 = "sha256-IMItXZPSFMTwS3uP+iQOBqf+cXwZh6obF2hliuYAI30=";
  };

  npmDepsHash = "sha256-jejcRiHXqhKWgikOeq5ED1VxHc0f3PjX+Nrv539a4f8=";

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
