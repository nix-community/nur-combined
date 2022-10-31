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

  # Enable WireGuard (TrackLib)
  networking.wireguard.interfaces = {

    wg0 = {

      ips = [ "10.0.0.126/32" ];

      privateKeyFile = "path to private key file";

      peers = [
        # For a client configuration, one peer entry for the server will suffice.

        {
          # Public key of the server (not a file path).
          publicKey = "{server public key}";

          # Forward all the traffic via VPN.
          allowedIPs = [ "0.0.0.0/0" ];
          # Or forward only particular subnets
          #allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];

          # Set this to the server IP and port.
          endpoint = "{server ip}:51820"; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };
  ...
}


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
