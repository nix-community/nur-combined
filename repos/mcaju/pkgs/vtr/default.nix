{ stdenv
, lib
, fetchFromGitHub
, bison
, cmake
, flex
, pkg-config
, tbb
}:

stdenv.mkDerivation rec {
  pname   = "vtr";
  version = "8.0.0-3049-g64d15e2d";

  src = fetchFromGitHub {
    owner  = "verilog-to-routing";
    repo   = "vtr-verilog-to-routing";
    rev    = "64d15e2ddda5860645220ec44e6baeadabc1b4c3";
    sha256 = "1b9qjki0r6i61wr4ph301bjilmiv3cd1bb62c9fw5mxav4da6ams";
  };

  nativeBuildInputs = [
    bison
    cmake
    flex
    pkg-config
  ];

  buildInputs = [
    tbb
  ];

  buildPhase = ''
    make CMAKE_PARAMS="-DCMAKE_INSTALL_PREFIX=$out" -j$NIX_BUILD_CORES
  '';

  postInstall = ''
    CAPNP_SCHEMAS=$out/bin/capnp-schemas-dir

    mkdir -p $out/lib
    mv $out/bin/*.a $out/lib/

    echo -e "#!/bin/bash\n\necho $out/capnp" > $CAPNP_SCHEMAS
    chmod +x $CAPNP_SCHEMAS
  '';

  meta = with lib; {
    description = "SymbiFlow WIP changes for Verilog to Routing (VTR)";
    homepage    = "https://github.com/SymbiFlow/vtr-verilog-to-routing";
    platforms   = platforms.all;
  };
}
