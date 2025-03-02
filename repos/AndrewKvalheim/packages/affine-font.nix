{ fetchFromGitea
, lib
, stdenv
, unstableGitUpdater

  # Dependencies
, fontforge
}:

stdenv.mkDerivation {
  pname = "affine-font";
  version = "0-unstable-2023-02-09";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "affine";
    rev = "ffc686a95586213079e4bd0ffb45f2e171aeb613";
    hash = "sha256-eE6CTcMwctSm8quGSbFsLDiwSw7h+sOFm7HaCMtHML0=";
  };

  nativeBuildInputs = [ fontforge ];

  buildPhase = "make otf";

  installPhase = "install -m444 -Dt $out/share/fonts/opentype build/*.otf";

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    homepage = "https://codeberg.org/AndrewKvalheim/affine";
    license = lib.licenses.cc-by-nc-sa-40;
  };
}
