{
  pkgs,
  inputs,
  ...
}:

let
  kernel = pkgs.cachyosKernels.linux-cachyos-rc.override {
    lto = "thin";
    processorOpt = "zen4";
    bbr3 = true; # TCP congestion control
    acpiCall = true;
  };
  kernelPackagesWithLTOFix =
    let
      helpers = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" { };
    in
    helpers.kernelModuleLLVMOverride (pkgs.linuxKernel.packagesFor kernel);
in

{
  imports = [
    ./gnome.nix
    ./niri.nix
    ./rime
    ./fonts.nix
    ./hardware.nix
    ./services.nix
    ./virt.nix
    ./networking.nix
    ./vaultix.nix
    ./btrbk.nix
    ./persist.nix
  ];

  # userborn
  services.userborn.enable = true;

  boot = {
    plymouth.enable = true;
    loader = {
      limine.enable = true;
      limine.maxGenerations = 5;
      limine.secureBoot.enable = true;
      limine.extraEntries = ''
        /Windows
        protocol: efi
        path: uuid(6335ba1a-25e9-45e6-aa31-6d82c83c07f5):/EFI/Microsoft/Boot/bootmgfw.efi
      '';
      efi.canTouchEfiVariables = true;
    };
    # kernelPackages = pkgs.linuxPackages_latest;
    #kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;
    kernelPackages = kernelPackagesWithLTOFix;

    kernelParams = [
      "splash"
      "quiet"
      "nowatchdog"
      "audit=0"
      "amd_pstate=active"
      "amd_iommu=on"
      "iommu=pt"
      "pti=on"
      "loglevel=3"
      "udev.log_level=3"
      "rcutree.enable_rcu_lazy=1"
    ];
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.TERMINAL = [ "kitty" ];
  environment.variables."EDITOR" = "hx"; # @TODO https://github.com/nix-community/home-manager/issues/4969

  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-gtk3-1.1.12"
    "wechat-4.1.0.13"
  ];

  environment.pathsToLink = [ "/share/fish" ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.fish.enable = true;
  environment.systemPackages = [
    pkgs.sbctl
    pkgs.perf
    pkgs.squashfsTools
    pkgs.squashfuse
    pkgs.openvpn3
  ];
  programs.fuse.userAllowOther = true;
  services.flatpak.enable = true;
  security = {
    rtkit.enable = true;
    sudo.enable = false;
    sudo-rs.enable = true;
    sudo-rs.wheelNeedsPassword = false;
  };

  systemd.services.nix-daemon = {
    environment = {
      TMPDIR = "/var/cache/nix";
    };
    serviceConfig = {
      CacheDirectory = "nix";
    };
  };

  documentation.nixos.enable = false;

  system.stateVersion = "26.05";
}
