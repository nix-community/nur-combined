{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  binutils,
  libusb1,
  gnumake,
}:
stdenv.mkDerivation {
  pname = "xfel";
  version = "latest";

  src = fetchFromGitHub {
    owner = "xboot";
    repo = "xfel";
    rev = "1383b836cb933d5797a7394c6a9d2dbb061bdc95";
    sha256 = "sha256-PxxXtoQLSM9P+AZ6aqKKVDJZNjgbFw6SGRCo0jVXaDA=";
  };

  buildInputs = [
    pkg-config
    binutils
    libusb1
  ];

  nativeBuildInputs = [
    gnumake
  ];

  configurePhase = ''
    export DESTDIR=$out
  '';

  buildPhase = ''
    make -j`nproc`
  '';

  installPhase = ''
    make install
  '';

  meta = {
    description = "Tiny FEL tools for Allwinner SOC";
    homepage = "https://xboot.org/xfel";
    license = lib.licenses.mit;
  };
}
