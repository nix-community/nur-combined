{
  lib,
  stdenv,
  kernel ? null,
  linuxPackages,
}:

let
  linuxPkg = if kernel != null then kernel else linuxPackages.kernel;
in

stdenv.mkDerivation {
  pname = "bt-iso-enable";
  version = "0.1.0-${lib.substring 0 7 linuxPkg.version}";

  src = lib.cleanSource ./.;

  nativeBuildInputs = linuxPkg.moduleBuildDependencies;

  makeFlags = [
    "KDIR=${linuxPkg.dev}/lib/modules/${linuxPkg.modDirVersion}/build"
  ];

  installPhase = ''
    install -D bt-iso-enable.ko $out/lib/modules/${linuxPkg.modDirVersion}/extra/bt-iso-enable.ko
  '';

  meta = {
    description = "Kernel module to enable Bluetooth ISO sockets via kprobe-based iso_init call";
    homepage = "https://github.com/RhenCloud/nixos";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
