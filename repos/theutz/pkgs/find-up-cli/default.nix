{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "find-up";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "sindresorhus";
    repo = "find-up-cli";
    rev = "v${version}";
    hash = "sha256-h0qaTFfafQchPMOwju1vpoPimRzqmLFHNsjLvnokRxw=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-u1Qcacte3g8lsqITy5C+Gxm2ORZi0zr/WHIgHzINrbI=";

  dontNpmBuild = true;
  dontNpmPrune = true;

  meta = {
    description = "Find a file by walking up parent directories";
    homepage = "https://github.com/sindresorhus/find-up-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "find-up";
    platforms = lib.platforms.all;
  };
}
