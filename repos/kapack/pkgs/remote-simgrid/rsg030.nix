{ stdenv, lib, fetchgit
, ninja, meson, pkgconfig
, simgrid, boost, docopt_cpp, protobuf
, debug ? false
}:

stdenv.mkDerivation rec {
  pname = "remote-simgrid";
  version = "0.3.0";

  src = fetchgit {
    rev = "v${version}";
    url = "https://github.com/simgrid/remote-simgrid";
    sha256 = "0dwgq2dryckmhn5sl6kr9pdffbh78dw4v585m6wdd8571qa4y8r9";
  };

  nativeBuildInputs = [ meson pkgconfig ninja ];
  buildInputs = [ simgrid docopt_cpp boost ];
  propagatedBuildInputs = [ protobuf ];

  ninjaFlags = [ "-v" ];
  enableParallelBuilding = true;

  mesonBuildType = if debug then "debug" else "release";
  CXXFLAGS = if debug then "-O0" else "";
  hardeningDisable = if debug then [ "fortify" ] else [];
  dontStrip = debug;

  meta = with lib; {
    description = "A solution to execute your distributed application on top of SimGrid.";
    longDescription = ''
      Remote SimGrid allows to study real distributed applications by sandboxing their execution in a SimGrid simulation.
      This is done by managing a simulated world in a dedicated process (rsg_server), and by providing an API so that the distributed application processes connect to rsg_server.
      The provided API calls are blocking, which allows rsg_server to control how the processes should execute in accordance with its simulation.
    '';
    homepage = "https://framagit.org/simgrid/remote-simgrid";
    platforms = platforms.all;
    license = licenses.lgpl3;
    broken = false;
  };
}
