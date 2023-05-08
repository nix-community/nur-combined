{
  stdenv,
  fetchzip,
  libgta,
  pkg-config,
}:
stdenv.mkDerivation rec {
  pname = "gtatool";
  version = "2.4.0";

  src = fetchzip {
    url = "https://marlam.de/gta/releases/gtatool-${version}.tar.xz";
    hash = "sha256-la592sskqg89wAvQ0OMNJguvr68AKNX8jdSpTxwbzbw=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libgta
  ];

  # TODO
  meta.broken = true;
}
