{ stdenv, fetchFromGitHub, pkgconfig, cmake, boost, callPackage }:

stdenv.mkDerivation rec {
  pname = "ydotool";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "ReimuNotMoe";
    repo = "ydotool";
    rev = "v${version}";
    sha256 = "0mx3636p0f8pznmwm4rlbwq7wrmjb2ygkf8b3a6ps96a7j1fw39l";
  };

  # disable static linking
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace \
      "-static" \
      ""
  '';

  libuInputPlus = callPackage ./libuInputPlus.nix { };
  libevdevPlus = callPackage ./libevdevPlus.nix { };

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [
    boost libevdevPlus libuInputPlus
  ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/ReimuNotMoe/ydotool";
    description = "Generic Linux command-line automation tool";
    license = licenses.mit;
    platforms = with platforms; linux;
  };
}
