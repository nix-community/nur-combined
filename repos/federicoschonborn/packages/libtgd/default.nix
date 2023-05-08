{
  stdenv,
  fetchzip,
  cmake,
}:
stdenv.mkDerivation rec {
  pname = "libtgd";
  version = "4.2";

  src = fetchzip {
    url = "https://marlam.de/tgd/releases/tgd-${version}.tar.gz";
    hash = "sha256-raVdV54pemMD3J+uyKmICZFcRCdl/tjIOysTtZPOF4E=";
  };

  nativeBuildInputs = [
    cmake
  ];
}
