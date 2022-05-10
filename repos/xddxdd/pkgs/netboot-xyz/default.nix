{ lib
, stdenv
, sources
, ...
} @ args:

assert (sources.netboot-xyz-lkrn.version == sources.netboot-xyz-lkrn.version);
stdenv.mkDerivation rec {
  name = "netboot.xyz";
  inherit (sources.netboot-xyz-lkrn) version;

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir $out
    cp ${sources.netboot-xyz-efi.src} $out/netboot.xyz.efi
    cp ${sources.netboot-xyz-lkrn.src} $out/netboot.xyz.lkrn
  '';

  meta = with lib; {
    description = "Your favorite operating systems in one place. A network-based bootable operating system installer based on iPXE.";
    homepage = "https://netboot.xyz/";
    license = licenses.asl20;
  };
}
