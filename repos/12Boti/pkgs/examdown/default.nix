{ lib
, stdenv
, fetchFromGitHub
, getopt
, cmark-gfm
, wkhtmltopdf
, gnused
, makeWrapper
, runCommand
}:
let
  deps = [
    getopt
    cmark-gfm
    wkhtmltopdf
    gnused
  ];
  src = fetchFromGitHub {
    owner = "pldiiw";
    repo = "examdown";
    rev = "574ae6e3f4033080c6d19909829fc7e4c82a3b65";
    sha256 = "sha256-Lbz9Xk5bNdcsgc0y/oBBnJOtDE1EtHOUcB3M3axabnI=";
    fetchSubmodules = true;
  };
  examdown =
    stdenv.mkDerivation
      {
        name = "examdown";
        inherit src;
        buildPhase = ''
          patchShebangs .
          sed -i 's/cmark/cmark-gfm --unsafe/g' src/examdown.sh
          sed -i "s|wkhtmltopdf|wkhtmltopdf --enable-local-file-access|g" src/examdown.sh
          make -s checkdeps
          make -s build
        '';
        installPhase = ''
          mkdir $out
          make -s install PREFIX=$out
          wrapProgram $out/bin/examdown --prefix PATH : ${lib.makeBinPath deps}
        '';
        buildInputs = deps;
        nativeBuildInputs = [
          makeWrapper
        ];
        passthru.tests = {
          simple = runCommand "test" { } ''
            ${examdown}/bin/examdown -o out.pdf ${src}/test/test.md
            cp out.pdf $out
          '';
        };
        meta.broken = true; # depends on qtwebkit, which is insecure
      };
in
examdown
