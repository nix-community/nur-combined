{ stdenv, fetchgit, callPackage, cmake, libXrandr }:
let
  libthinkpad = callPackage ../libthinkpad {};
in

stdenv.mkDerivation rec {
  pname = "dockd";
  version = "1.21";

  src = fetchgit {
    url = "https://github.com/libthinkpad/dockd";
    rev = version;
    sha256 = "1fr9r19b04ac92ynz62rnzgc6jfzxrf76k3m6szspgw7sx9rhjc2";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ libthinkpad libXrandr ];

  postPatch = ''
    sed -i '/etc/d' CMakeLists.txt
  '';

  buildPhase = ''
    cmake . -DCMAKE_INSTALL_PREFIX=$out
    make
  '';

  meta = {
    homepage = "https://github.com/libthinkpad/dockd";
    description = "Lenovo ThinkPad Dock Management Daemon.";
  };
}
