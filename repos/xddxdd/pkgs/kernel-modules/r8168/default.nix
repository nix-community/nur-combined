{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "r8168";
  version = "8.057.00";
  src = fetchFromGitHub {
    owner = "mtorromeo";
    repo = "r8168";
    tag = finalAttrs.version;
    hash = "sha256-KymQThzYKpcgCjKX3ZQ2RAWNga2d0EaWXVQmHzw8hmA=";
  };
  postPatch = ''
    sed -i 's/$(KERNELDIR)/''${KSRC}/g' src/Makefile
    sed -i 's/$(RTKDIR)/updates/g' src/Makefile
  '';

  preConfigure = ''
    cd src
  '';

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  makeFlags = kernel.commonMakeFlags or kernel.makeFlags;

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Linux device driver for Realtek Ethernet controllers";
    homepage = "https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
  };
})
