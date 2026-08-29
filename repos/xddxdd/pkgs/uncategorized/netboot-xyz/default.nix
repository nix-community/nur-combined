{
  fetchurl,
  lib,
  stdenv,
}:
let
  netbootXyzEfiSrc = fetchurl {
    url = "https://github.com/netbootxyz/netboot.xyz/releases/download/3.0.3-RC/netboot.xyz.efi";
    hash = "sha256-S0UrpWQR20RKdpoDWFnlf9kDJ+lX62wD5/KXHR1sNtU=";
  };
  netbootXyzLkrnSrc = fetchurl {
    url = "https://github.com/netbootxyz/netboot.xyz/releases/download/3.0.3-RC/netboot.xyz.lkrn";
    hash = "sha256-vg8A15ovXd/owk7vDCGQaZIaG2jD5NVvGcxKi2SAnDc=";
  };
in
assert ("3.0.2" == "3.0.2");
stdenv.mkDerivation (finalAttrs: {
  pname = "netboot-xyz";
  version = "3.0.3-RC";
  dontUnpack = true;
  postInstall = ''
    mkdir $out
    cp ${netbootXyzEfiSrc} $out/netboot.xyz.efi
    cp ${netbootXyzLkrnSrc} $out/netboot.xyz.lkrn
  '';

  passthru.updateScript = [ (toString ./update.sh) ];
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Network-based bootable operating system installer based on iPXE";
    homepage = "https://netboot.xyz/";
    license = lib.licenses.asl20;
  };
})
