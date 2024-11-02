{
  stdenv,
  lib,
  sources,
  kernel,
}:
stdenv.mkDerivation rec {
  inherit (sources.ovpn-dco) pname version src;

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
    "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  prePatch = ''
    # Skip depmod
    substituteInPlace Makefile \
      --replace "INSTALL_MOD_DIR=updates/" "INSTALL_MOD_PATH=${placeholder "out"}/" \
      --replace "DEPMOD := depmod -a" "DEPMOD := true"
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "OpenVPN Data Channel Offload in the linux kernel";
    homepage = "https://github.com/OpenVPN/ovpn-dco";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
