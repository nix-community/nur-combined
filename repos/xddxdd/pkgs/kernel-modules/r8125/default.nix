{
  stdenv,
  lib,
  sources,
  kernel,
}:
stdenv.mkDerivation rec {
  inherit (sources.r8125) pname version src;

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

  makeFlags =
    if lib.hasAttr "moduleMakeFlags" kernel then kernel.moduleMakeFlags else kernel.makeFlags;

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Linux device driver for Realtek 2.5/5 Gigabit Ethernet controllers with PCI-Express interface";
    homepage = "https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
  };
}
