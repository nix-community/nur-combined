{ config, lib, pkgs, ... }:
with lib;
let
  base = import ./base-defaults.nix { inherit config pkgs lib; };
in
recursiveUpdate base {
  environment.systemPackages = with pkgs; [
    # misc tools
    cryptsetup
    file
    htop
    mosh
    psmisc
    pv
    pwgen
    tcpdump
    tree
    wget
    wireguard
  ];


  # --- Program options ---
  programs.screen.screenrc = readFile ./files/.screenrc;

  # This requires the kampka nur packages
  kampka.programs.direnv = {
    enable = mkDefault true;
    configureBash = mkDefault true;
  };


  # --- Service options ---

  services.fail2ban.enable = mkDefault true;
  services.lorri.enable = mkDefault true;

  ## Enable the OpenSSH daemon.
  services.openssh = {
    enable = mkDefault true;
    logLevel = mkDefault "ERROR";
    passwordAuthentication = mkDefault false;
  };

  kampka.services.ntp.enable = mkDefault true;

  # This requires the priegger nur packages
  priegger.services.cachix.enable = mkDefault true;
  priegger.services.prometheus.enable = mkDefault true;
  priegger.services.tor.enable = mkDefault true;
}
