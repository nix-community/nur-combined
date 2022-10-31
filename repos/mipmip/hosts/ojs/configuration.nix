{ config, inputs, system, pkgs, ... }:

let
  myCustomLayout = pkgs.writeText "xkb-layout" ''
    clear lock
    ! disable capslock
    ! remove Lock = Caps_Lock
  '';
in
  {
    imports = [

      ./hardware-configuration.nix
      ../../shared-configuration.nix

      ../../modules/base-minimal.nix
      ../../modules/common.nix
      ../../modules/common-pkg.nix
      ../../modules/modern-unix.nix
      ../../modules/dev-crystal.nix
      ../../modules/dev-quiqr.nix
      ../../modules/dev-technative.nix
      ../../modules/vim-large.nix
      ../../modules/workstation.nix
      ../../modules/docker.nix
      ../../modules/virtualbox.nix
#      ../../modules/comma.nix
      ../../modules/workstation-pkg.nix

      ../../modules/home-manager-global.nix

      ../../modules/texlive.nix
      ../../modules/fonts.nix
      ../../modules/st.nix
      ../../modules/terminal.nix
      ../../modules/office-communication.nix
      ../../modules/browser-firefox.nix
      ../../modules/browser-chrome.nix
      ../../modules/nfspiet.nix
      ../../modules/peripherals_hurwenen.nix
      ../../modules/nixos-utils.nix
      ../../modules/explore-pkg.nix
      ../../modules/hardware.nix
  ];


  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
            experimental-features = nix-command flakes
    '';
  };

  networking.hosts = {
      "127.0.0.1" = [ "ojs" "localhost" ];
      "213.206.241.6" = [ "buwa.nl" "www.buwa.nl" ];
#      "3.68.90.166" = ["technative.nl" "www.technative.nl"];
    };


  services.xserver.displayManager.sessionCommands = "${pkgs.xorg.xmodmap}/bin/xmodmap ${myCustomLayout}";

  networking.hostName = "ojs";
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  networking.useDHCP = false;
  networking.interfaces.enp10s0.useDHCP = true;
  networking.interfaces.enp9s0.useDHCP = true;
  networking.interfaces.wlp0s29f7u5.useDHCP = true;

  # Enable WireGuard
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.0.0.126/32" ];
      privateKeyFile = "/etc/secrets/wg-tracklib-key";
      peers = [
        {
          publicKey = "QGTFSDQ3KirYWvoUaLeVvWkupuDGy+0Kw5o5w3i6bBk=";
          allowedIPs = [
            "18.34.240.0/22"
            "18.34.32.0/20"
            "3.248.191.174/32"
            "3.249.205.218/32"
            "3.251.110.208/28"
            "3.251.110.224/28"
            "3.5.64.0/21"
            "3.5.72.0/23"
            "34.240.195.73/32"
            "34.242.244.140/32"
            "34.244.143.75/32"
            "34.245.13.201/32"
            "34.246.190.131/32"
            "34.253.203.229/32"
            "34.253.65.159/32"
            "52.17.210.58/32"
            "52.214.62.56/32"
            "52.214.93.103/32"
            "52.215.227.9/32"
            "52.218.0.0/17"
            "52.49.234.215/32"
            "52.50.3.164/32"
            "52.92.0.0/17"
            "54.229.51.218/32"
            "63.33.57.42/32"
            "63.33.80.225/32"
          ];

          endpoint = "108.128.244.6:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #KEYCHRON KEYBOARD SWAP FN KEY
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';
  boot.kernelModules = [ "hid-apple"  ];

  #NIEUWE POGING
  boot.kernelParams = [
    "hid_apple.fnmode=2"
  ];

  boot.extraModulePackages = [
    config.boot.kernelPackages.broadcom_sta
#    config.boot.kernelPackages.wireguard
  ];



  system.stateVersion = "21.11"; # Did you read the comment?
}
