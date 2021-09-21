{ stdenv, lib, fetchFromGitLab
, meson, ninja, pkgconfig
, simgrid, intervalset, boost, rapidjson, redox, hiredis, libev, zeromq, docopt_cpp, pugixml
, debug ? false
}:

stdenv.mkDerivation rec {
  pname = "batsim";
  version = "3.1.0";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "batsim";
    repo = pname;
    rev = "v${version}";
    sha256 = "1yyga9mj76k316rm4qp2sjhgkm03213d855n2j8fjnd2ikdj7zm6";
  };

  # Temporary hack. Meson is no longer able to pick up Boost automatically.
  # https://github.com/NixOS/nixpkgs/issues/86131
  BOOST_INCLUDEDIR = "${lib.getDev boost}/include";
  BOOST_LIBRARYDIR = "${lib.getLib boost}/lib";

  nativeBuildInputs = [
    meson
    ninja
    pkgconfig
  ];
  # runtimeDeps is used to generate multi-layered docker contained
  runtimeDeps = [
    simgrid
    intervalset
    boost
    rapidjson
    redox
    hiredis
    libev
    zeromq
    docopt_cpp
    pugixml
  ];
  buildInputs = runtimeDeps;

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
