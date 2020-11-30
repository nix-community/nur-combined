{ config, lib, pkgs, ... }:
with lib;

{
  # Select internationalisation properties.
  i18n = {
    defaultLocale = mkDefault "en_US.UTF-8";
  };

  environment.variables = {
    LC_TIME = mkDefault "en_GB.UTF-8";
    LC_PAPER = mkDefault "en_GB.UTF-8";
    LC_MEASUREMENT = mkDefault "en_GB.UTF-8";
  };

  console = {
    font = mkDefault "Lat2-Terminus16";
    keyMap = mkDefault "de";
  };

  # Set your time zone.
  time.timeZone = mkDefault "Europe/Berlin";

  # Increase size of /run/user directories
  services.logind.extraConfig = ''
    RuntimeDirectorySize=2G
  '';

  # Reduce journal size
  services.journald.extraConfig = ''
    Storage=persistent
    SystemMaxUse=512M
  '';

  # Improved bash history settings
  environment.variables = {
    HISTSIZE = mkDefault "10000";
    HISTFILESIZE = mkDefault "20000";
    HISTTIMEFORMAT = mkDefault "%Y-%m-%d %T ";
  };

  # Make firewall less verbose
  networking.firewall.logRefusedConnections = mkDefault false;

  # Nix options
  nix = {
    autoOptimiseStore = mkDefault true;
    useSandbox = mkDefault true;
  };

  # Clean the tmp dir
  boot.cleanTmpDir = mkDefault (! config.boot.tmpOnTmpfs);


  # --- Program options ---
  programs.bash.enableCompletion = mkDefault true;
  programs.vim.defaultEditor = mkDefault true;
}
