{ stdenv, lib, fetchFromGitLab
, meson, ninja, pkgconfig
, simgrid, intervalset, boost, rapidjson, redox, zeromq, docopt_cpp, pugixml
, debug ? false
}:

stdenv.mkDerivation rec {
  pname = "batsim";
  version = "4.0.0";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "batsim";
    repo = pname;
    rev = "v${version}";
    sha256 = "0lr3vawdbmajisgvbj5cjqw0wfy9y990yhl20kplarambx40nplp";
  };
  patches = [ ./fix-missing-include-gcc-9-to-10.patch ];

  nativeBuildInputs = [
    meson
    ninja
    pkgconfig
  ];
  # runtimeDeps is used to generate multi-layered docker contained
  runtimeDeps = [
    simgrid
    intervalset
    rapidjson
    redox
    zeromq
    docopt_cpp
    pugixml
  ];
  buildInputs = [
    boost
  ] ++ runtimeDeps;

  ninjaFlags = [ "-v" ];
  enableParallelBuilding = true;

  mesonBuildType = if debug then "debug" else "release";
  CXXFLAGS = if debug then "-O0" else "";
  hardeningDisable = if debug then [ "fortify" ] else [];
  dontStrip = debug;

  meta = with lib; {
    description = "An infrastructure simulator that focuses on resource management techniques.";
    homepage = "https://framagit.org/batsim/batsim";
    platforms = platforms.all;
    license = licenses.lgpl3;
    broken = false;

    longDescription = ''
      Batsim is an infrastructure simulator that enables the study of resource management techniques.
    '';
  };
}
