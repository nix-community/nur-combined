{ stdenv
, lib
, buildDate
, commit
, bin
, devices
}:

stdenv.mkDerivation rec {
  name   = "symbiflow-arch-defs";
  version = "${buildDate}-g${commit}";

  phases = [ "installPhase" "fixupPhase" ];

  buildInputs = [ bin ] ++ devices;
  
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${bin}/bin/* $out/bin/

    mkdir -p $out/share/symbiflow
    ln -s ${bin}/share/symbiflow/* $out/share/symbiflow/

    mkdir -p $out/share/symbiflow/arch
    for device in ${builtins.concatStringsSep " " devices}; do
      ln -s $device/share/symbiflow/arch/* $out/share/symbiflow/arch/
    done
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "Project X-Ray - Xilinx Series 7 Bitstream Documentation";
    homepage    = "https://github.com/SymbiFlow/symbiflow-arch-defs";
    license     = licenses.isc;
    platforms   = platforms.all;
  };
}
