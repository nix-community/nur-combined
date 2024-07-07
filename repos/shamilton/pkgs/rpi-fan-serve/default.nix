{ lib
, mkDerivation
, fetchFromGitHub
, meson
, ninja
, pkg-config
, cmake
, qtbase
, argparse
, brotli
, c-ares
, cppzmq
, drogon
, jsoncpp
, libconfig
, libuuid
, openssl
, sqlite
, systemd
, tbb
, zeromq
}:

mkDerivation {
  pname = "rpi-fan-serve";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "rpi-fan-serve";
    rev = "45818cbd03e94f672f4c82ceb4d715bc87b1cb78";
    sha256 = "1y2vrfyj7hi415dh6kyc3dyd9k9mg9dqhlha51lg0iqnvnp02zl0";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ninja meson cmake ];

  buildInputs = [
    argparse
    brotli
    c-ares
    cppzmq
    drogon
    jsoncpp
    libconfig
    libuuid
    openssl
    sqlite
    systemd
    tbb
    zeromq
    qtbase
  ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "A web service to access rpi-fan data";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/rpi-fan-serve";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
