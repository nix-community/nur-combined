{
  inputs,
  outputs,
  lib,
  pkgs,
  nixosModules,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
  ]
  ++ (with nixosModules.programs; [
    nix
    gnupg
  ]);

  boot = {
    initrd.systemd.enable = lib.mkDefault true;

    loader = {
      efi.canTouchEfiVariables = lib.mkDefault true;

      systemd-boot = {
        enable = lib.mkDefault true;
        # configurationLimit = 50;
        editor = false;
      };
    };
  };

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
  };

  # Pick only one of the below networking options.
  # networking.wireless.enable = lib.mkDefault true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = lib.mkDefault true; # Easiest to use and most distros use this by default.

  console = {
    #font = "Lat2-Terminus16";
    packages = lib.mkDefault [ pkgs.terminus_font ];
    font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-i18b.psf.gz";
    keyMap = lib.mkDefault "la-latin1";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # List packages installed in system profile.
  environment.defaultPackages = lib.mkForce [ ];
  environment.systemPackages = with pkgs; [
    # bat
    bottom
    busybox
    fet-sh
    file
    fwupd
    git
    lshw
    # ripgrep
    sops
    tldr
  ];

  services.fwupd.enable = true;

  # security.polkit.enable = true;

  systemd = {
    # extraConfig = ''
    #   DefaultTimeoutStopSec=10s
    # '';
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  #system.stateVersion = "24.11"; # Did you read the comment?

}
