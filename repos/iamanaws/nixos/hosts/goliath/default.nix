{
  lib,
  pkgs,
  nixosModules,
  ...
}:

{
  imports = with nixosModules; [
    gaming
    hardened
    services.flatpak
  ];

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linuxKernel.kernels.linux_6_12;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix-mineral.settings.kernel.binfmt-misc = true;

  # specialisation."linux-6.18-no-dynamic-of".configuration =
  #   let
  #     fixedKernel = pkgs.linuxKernel.kernels.linux_6_18.override {
  #       # CONFIG_PCI_DYNAMIC_OF_NODES was the sole generated-config
  #       # difference between the bad and good Linux 6.19 bisect kernels.
  #       # MISC_RP1 selects it on 6.18, so disable that irrelevant module too.
  #       structuredExtraConfig = {
  #         MISC_RP1 = lib.mkForce lib.kernel.no;
  #         PCI_DYNAMIC_OF_NODES = lib.mkForce lib.kernel.no;
  #       };
  #     };
  #   in
  #   {
  #     # Linux 6.18 with the isolated boot workaround and otherwise normal host
  #     # settings, including GPU drivers, IOMMU, microcode, and quiet boot.
  #     boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor fixedKernel);

  #     system.nixos.tags = [ "6.18-no-dynamic-of" ];
  #   };

  # specialisation."debug-6.18-of-skip-invalid-bridge".configuration =
  #   let
  #     debugKernel = pkgs.linuxKernel.kernels.linux_6_18;
  #   in
  #   {
  #     # Keep normal dynamic OF behavior, generically skipping bridges whose
  #     # primary/secondary/subordinate bus registers are invalid.
  #     boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor debugKernel);
  #     boot.kernelPatches = [
  #       {
  #         name = "debug-pci-of-skip-invalid-bridge";
  #         patch = pkgs.writeText "debug-pci-of-skip-invalid-bridge.patch" ''
  #           diff --git a/drivers/pci/of.c b/drivers/pci/of.c
  #           --- a/drivers/pci/of.c
  #           +++ b/drivers/pci/of.c
  #           @@ -670,2 +670,3 @@ void of_pci_make_dev_node(struct pci_dev *pdev)
  #            	const char *name;
  #           +	u32 buses;
  #            	int ret;
  #           @@ -677,2 +678,10 @@ void of_pci_make_dev_node(struct pci_dev *pdev)
  #            	if (pci_device_to_OF_node(pdev))
  #            		return;
  #           +
  #           +	pci_read_config_dword(pdev, PCI_PRIMARY_BUS, &buses);
  #           +	if ((buses & 0xff) != pdev->bus->number ||
  #           +	    ((buses >> 8) & 0xff) <= pdev->bus->number ||
  #           +	    ((buses >> 8) & 0xff) > ((buses >> 16) & 0xff)) {
  #           +		pci_info(pdev, "skipping dynamic OF node for invalid bridge\n");
  #           +		return;
  #           +	}
  #         '';
  #       }
  #     ];

  #     system.nixos.tags = [ "6.18-of-skip-invalid-bridge" ];
  #   };

  services.xserver.xkb.layout = "latam";

  services.flatpak.packages = [
    "net.sourceforge.VMPK"
    "com.github.tchx84.Flatseal"
    # "io.github.nokse22.asciidraw"
    # "app.drey.EarTag"
    # "xyz.slothlife.Jogger"
    # "com.jeffser.Alpaca"
    # mission center
    # garden.jamie.Morphosis
  ];

  programs.solaar.enable = true;
  programs.zoom-us.enable = true;

  # Keep GNOME as the default, but select Hyprland for iamanaws.
  systemd.services.display-manager.preStart = lib.mkAfter ''
    busctl=${pkgs.systemd}/bin/busctl
    read -r _ account_path < <(
      "$busctl" call \
        org.freedesktop.Accounts /org/freedesktop/Accounts \
        org.freedesktop.Accounts FindUserByName s iamanaws
    )
    account_path="''${account_path//\"/}"

    for setting in SetSession:hyprland SetSessionType:wayland; do
      "$busctl" call org.freedesktop.Accounts "$account_path" \
        org.freedesktop.Accounts.User "''${setting%%:*}" s "''${setting#*:}"
    done
  '';

  environment.systemPackages = with pkgs; [
    aseprite
    egl-wayland
    libva-utils
    libreoffice
    rapidraw
    reaper
  ];

  # Force intel-media-driver (iHD / i915) or nvidia
  environment.sessionVariables = {
    # VDPAU_DRIVER = "va_gl";
    NVD_BACKEND = "direct";
    LIBVA_DRIVER_NAME = "nvidia";
    MOZ_DISABLE_RDD_SANDBOX = "1";

    # GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # WLR_NO_HARDWARE_CURSORS = "1";
  };

}
