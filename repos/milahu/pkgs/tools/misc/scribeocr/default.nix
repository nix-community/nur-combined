# https://ryantm.github.io/nixpkgs/languages-frameworks/javascript/#javascript-buildNpmPackage

{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  python3,
}:

buildNpmPackage rec {
  pname = "scribeocr";
  version = "unstable-2025-07-09";

  src = fetchFromGitHub {
    owner = "scribeocr";
    repo = "scribeocr";
    rev = "734c0547776e1a752c585415321c98b7a473a2f0";
    hash = "sha256-R5kXWhzKNk0NEsBVg4BVg6NHJe+YdMQgdLA2DrFvwNY=";
    fetchSubmodules = true;
  };

  npmDepsHash = "sha256-oXVKxPJmo7Kk2BYWhmkFYAPdL+hPSSHh/T3pTci8x+g=";

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    cat >$out/bin/scribeocr <<EOF
    #!/bin/sh
    exec ${python3}/bin/python -m http.server --directory $out/lib/node_modules/scribeocr/
    EOF
    chmod +x $out/bin/scribeocr
  '';

  meta = {
    description = "Web interface for recognizing text, proofreading OCR, and creating fully-digitized documents [hocr editor]";
    homepage = "https://github.com/scribeocr/scribeocr";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "scribeocr";
    platforms = lib.platforms.all;
  };
}
