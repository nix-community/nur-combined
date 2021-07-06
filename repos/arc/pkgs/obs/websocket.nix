{ fetchFromGitHub, stdenv, obs-studio, cmake, ninja, lib, qtbase ? qt5.qtbase, qt5, websocketpp, asio_1_10 }: stdenv.mkDerivation rec {
  pname = "obs-websocket";
  version = "4.9.1";

  src = fetchFromGitHub {
    owner = "Palakis";
    repo = pname;
    rev = version;
    sha256 = "1gcy31531fc1c1iia3f768ma7c753h99dn46vjzgn0z2chsr4a2w";
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [ obs-studio qtbase websocketpp asio_1_10 ];
  dontWrapQtApps = true;

  meta.broken = lib.versionOlder obs-studio.version "27";
}
