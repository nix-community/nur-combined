{ stdenv
, lib
, fetchFromGitHub
, yosys
, zlib
, readline
}:

stdenv.mkDerivation rec {
  pname   = "symbiflow-yosys-plugins";
  version = "1.0.0.7-194-g40efa517";

  src = fetchFromGitHub {
    owner  = "SymbiFlow";
    repo   = "yosys-symbiflow-plugins";
    rev    = "40efa517423c54119440733f34dbd4e0eb14f983";
    sha256 = "1178h6aqgnc060j1aj4af0bzhhx1fcbqisg86zf80gia3ixm71z3";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ yosys ];

  buildInputs = [
    readline
    zlib
  ];

  patchPhase = ''
    substituteInPlace xdc-plugin/xdc.cc \
      --replace 'proc_share_dirname()' "std::string(\"$out/share/yosys\")"
  '';

  makeFlags = [ "PLUGINS_DIR=$(out)/share/yosys/plugins" ];

  meta = with lib; {
    description = "Yosys SymbiFlow Plugins";
    homepage    = "https://github.com/SymbiFlow/yosys-symbiflow-plugins";
    license     = licenses.isc;
    platforms   = platforms.all;
  };
}
