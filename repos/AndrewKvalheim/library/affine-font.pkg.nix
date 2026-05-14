{ fetchFromGitea
, lib
, stdenv
, unstableGitUpdater

  # Dependencies
, fontforge
}:

let
  inherit (lib) licenses;
in
stdenv.mkDerivation {
  pname = "affine-font";
  version = "0-unstable-2023-02-09";
  meta = {
    homepage = "https://codeberg.org/AndrewKvalheim/affine";
    license = licenses.cc-by-nc-sa-40;
  };

  passthru.updateScript = unstableGitUpdater { };

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "affine";
    rev = "ffc686a95586213079e4bd0ffb45f2e171aeb613";
    hash = "sha256-eE6CTcMwctSm8quGSbFsLDiwSw7h+sOFm7HaCMtHML0=";
  };

  nativeBuildInputs = [ fontforge ];
  buildPhase = ''
    runHook preBuild

    make otf

    runHook postBuild
  '';

  installPhase = ''
    mkdir --parents "$out/share/fonts/opentype"
    cp --target-directory "$out/share/fonts/opentype" \
      build/*.otf
  '';
}
