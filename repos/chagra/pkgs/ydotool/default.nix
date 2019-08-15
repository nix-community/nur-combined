{ stdenv, fetchFromGitHub, boost, callPackage, cmake, enableDebugging }:
stdenv.mkDerivation rec {
  pname = "ydotool";
  version = "0.1.5";

  libuInputPlus = callPackage ./libuInputPlus.nix { };
  libevdevPlus = callPackage ./libevdevPlus.nix { };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ libuInputPlus libevdevPlus boost ];

  src = fetchFromGitHub {
    owner = "ReimuNotMoe";
    repo = pname;
    rev = "v${version}";
    sha256 = "1abhbzc414hfzzh5f3vx9za8h6g1wy9vp63s9pzp6mc1wxhj0ck9";
  };
}
