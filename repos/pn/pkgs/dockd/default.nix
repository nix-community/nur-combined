{ stdenv, fetchgit, callPackage, cmake, libXrandr }:
let
  libthinkpad = callPackage ../libthinkpad {};
in

stdenv.mkDerivation rec {
  pname = "dockd";
  version = "1.3";

  src = fetchgit {
    url = "https://github.com/libthinkpad/dockd";
    rev = version;
    sha256 = "sha256:1bygsnp1svp978dnqlcy7n29qsgn087s8sm5cpy2d8kc2zscw126";
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
