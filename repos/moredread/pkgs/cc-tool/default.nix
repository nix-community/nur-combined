{ stdenv, fetchFromGitHub, libusb, boost, autoreconfHook, pkgconfig  }:

# TODO: needs cleanup and meta
stdenv.mkDerivation rec {
  pname = "cc-tool";
  version = "0.26";

  buildInputs = [
     libusb boost
   ];

  nativeBuildInputs = [ autoreconfHook pkgconfig ];

  #preConfigure = "./bootstrap";

  enableParallelBuilding = true;

  postInstall = ''
    mkdir -p $out/lib
    cp -r udev $out/lib
  '';

  src = fetchFromGitHub {
    owner = "dashesy";
    repo = "cc-tool";
    rev = "407fd7e1631768c724e7d78e56c0b042598a8c23";
    sha256 = "1q7zqib4rn5l8clk2hj7078rfyrjdwxzpyg4r10is31lq22zhxqj";
  };
}
