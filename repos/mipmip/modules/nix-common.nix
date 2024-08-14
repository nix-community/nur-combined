{ config, lib, pkgs, ... }:

{
  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  services.openssh.enable = true;

  services.cron.enable = true;
  #services.atd.enable = true;

  #services.lorri.enable = true;
  services.journald.extraConfig = "SystemMaxUse=100M";

  #programs.fish.enable = true;
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  users.users.pim = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
  };

  users.users.tim = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
  };

  users.users.annemarie = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
  };

  users.users.guest = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
  };

}
