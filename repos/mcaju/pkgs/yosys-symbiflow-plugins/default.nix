{ stdenv
, lib
, fetchFromGitHub
, python3
, yosys
, zlib
, readline
}:

stdenv.mkDerivation rec {
  pname   = "yosys-symbiflow-plugins";
  version = "1.0.0-7-338_g93157fb";

  src = fetchFromGitHub {
    owner  = "SymbiFlow";
    repo   = "yosys-symbiflow-plugins";
    rev    = "93157fbe34e3ea2df3d62be0fbc3c7106fbb9e7f";
    sha256 = "1gji1qlgrvzjbc4x5iik54lrcv5i1h2c28hv7j652h5myh3bgq78";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [
    python3
    yosys.src
  ];

  buildInputs = [
    readline
    yosys
    zlib
  ];

  patchPhase = ''
    substituteInPlace xdc-plugin/xdc.cc \
      --replace 'proc_share_dirname()' "std::string(\"$out/share/yosys\")"
  '';

  preBuild = ''
    pushd ql-qlf-plugin
    mkdir -p pmgen
    cp ${yosys.src}/passes/pmgen/pmgen.py pmgen/
    python3 pmgen/pmgen.py -o pmgen/ql-dsp-pm.h -p ql_dsp ql_dsp.pmg
    popd
  '';

  makeFlags = [
    "PLUGINS_DIR=$(out)/share/yosys/plugins"
    "DATA_DIR=$(out)/share/yosys"
  ];

  meta = with lib; {
    description = "Yosys SymbiFlow Plugins";
    homepage    = "https://github.com/SymbiFlow/yosys-symbiflow-plugins";
    license     = licenses.isc;
    platforms   = platforms.all;
  };
}
