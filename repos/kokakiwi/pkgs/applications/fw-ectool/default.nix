{
  lib,
  stdenv,
  fetchgit,
  cmake,
  pkg-config,
  libusb1,
  libftdi1,
}:
stdenv.mkDerivation {
  pname = "fw-ectool";
  version = "unstable-2024-06-23";

  src = fetchgit {
    url = "https://gitlab.howett.net/DHowett/ectool.git";
    rev = "0ac6155abbb7d4622d3bcf2cdf026dde2f80dad7";
    hash = "sha256-XfDE+P9BxTvTCeuZjnjCmS1CN7hz79WM5MaHq/Smpq0=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libusb1
    libftdi1
  ];

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm0755 src/ectool $out/bin/ectool
    ln -s $out/bin/ectool $out/bin/fw-ectool

    runHook postInstall
  '';

  meta = {
    description = "ChromeOS EC Tool";
    homepage = "https://gitlab.howett.net/DHowett/ectool";
    license = lib.licenses.bsd3;
    mainProgram = "ectool";
    platforms = lib.platforms.all;
  };
}
