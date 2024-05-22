{ fetchFromGitea
, lib
, stdenv
, unstableGitUpdater

  # Dependencies
, fontforge
}:

stdenv.mkDerivation {
  pname = "affine-font";
  version = "unstable-2023-02-09";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "affine";
    rev = "7244376bfad1de2409d8081054f58fe97e611953";
    hash = "sha256-KwNO+DKs2JTZSs8dwFFZFDsb30TtWTTTySh+BiERd1g=";
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
