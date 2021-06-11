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
  version = "8.0.0-3722-g3701c52ce";

  src = fetchFromGitHub {
    owner  = "verilog-to-routing";
    repo   = "vtr-verilog-to-routing";
    rev    = "3701c52ce10fed932d17bd82ff95302c526ab523";
    sha256 = "1d2lzgaajm80ia1xnpfq2r3zp4shipiy6s5zmq7axdczz3j26nn4";
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
    description = "Verilog to Routing -- Open Source CAD Flow for FPGA Research";
    homepage    = "https://verilogtorouting.org/";
    platforms   = platforms.all;
    license     = licenses.mit;
  };
}
