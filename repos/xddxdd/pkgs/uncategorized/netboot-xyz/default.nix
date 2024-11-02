{
  lib,
  stdenvNoCC,
  sources,
}:
assert (sources.netboot-xyz-lkrn.version == sources.netboot-xyz-lkrn.version);
stdenvNoCC.mkDerivation rec {
  pname = "netboot-xyz";
  inherit (sources.netboot-xyz-lkrn) version;

  dontUnpack = true;
  postInstall = ''
    mkdir $out
    cp ${sources.netboot-xyz-efi.src} $out/netboot.xyz.efi
    cp ${sources.netboot-xyz-lkrn.src} $out/netboot.xyz.lkrn
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Your favorite operating systems in one place. A network-based bootable operating system installer based on iPXE";
    homepage = "https://netboot.xyz/";
    license = lib.licenses.asl20;
  };
}
