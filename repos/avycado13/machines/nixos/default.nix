{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  helpers = import ../../flakeHelpers.nix inputs;
in
{
  nixpkgs = helpers.nixpkgsCfg;
  imports = [ ../../modules/nix/default.nix ];

  nix-mineral = {
    # enable = lib.mkDefault true;
    enable = false;
    preset = "compatibility";
  };

  # Monitor disk health where drives are present; no-op on VMs/SD cards
  services.smartd = {
    enable = false;
    autodetect = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  users.users.avy = {
    isNormalUser = true;
    home = "/home/avy";
    description = "avy";
    extraGroups = lib.mkDefault [
      "wheel"
      "navidrome"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPm9/uwsYQ2KrzaVcpulcDUKnBOCMCYogfC+D+TcrK7"
    ];
  };

  programs.nix-index-database.comma.enable = true;
  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "${pkgs.systemd}/bin/systemctl suspend";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/poweroff";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
    wheelNeedsPassword = false;
  };
  time.timeZone = "America/Los_Angeles";

  services.tailscale.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
  };

  documentation.nixos.enable = false;

  environment.systemPackages = with pkgs; [
    helix
    rclone
    magic-wormhole
    htop
    curl
    git
    zmx
    inputs.niks3.packages.${pkgs.stdenv.hostPlatform.system}.niks3
  ];
  nix.settings.auto-optimise-store = true;
}
