{
  fetchurl,
  lib,
  stdenv,
}:
let
  netbootXyzEfiSrc = fetchurl {
    url = "https://github.com/netbootxyz/netboot.xyz/releases/download/3.0.2/netboot.xyz.efi";
    hash = "sha256-4PbBxZPh2grQg/nXoOOjWAhR9gJqNgR53oriAUrv0i8=";
  };
  netbootXyzLkrnSrc = fetchurl {
    url = "https://github.com/netbootxyz/netboot.xyz/releases/download/3.0.2/netboot.xyz.lkrn";
    hash = "sha256-XuynuqxT/TVo+1FmhGmzPcQF8mF2TN+wxwxlp6HCSOE=";
  };
in
assert ("3.0.2" == "3.0.2");
stdenv.mkDerivation (finalAttrs: {
  pname = "netboot-xyz";
  version = "3.0.2";
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
