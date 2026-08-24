{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "r8125";
  version = "9.018.00-1";
  src = fetchFromGitHub {
    owner = "awesometic";
    repo = "realtek-r8125-dkms";
    tag = finalAttrs.version;
    hash = "sha256-yeQsyraNrms1Txm7ZAKeiPfF0tfN6WSHUo5DnvfFosw=";
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
    description = "Linux device driver for Realtek 2.5/5 Gigabit Ethernet controllers with PCI-Express interface";
    homepage = "https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
  };
})
