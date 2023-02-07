{
  config,
  lib,
  pkgs,
  ...
}: let
  secrets = config.my.secrets;
in {
  users.mutableUsers = false;
  users.users.root = {
    passwordFile = config.age.secrets."users/root-hashed-password".path;
  };
  users.users.alarsyo = {
    passwordFile = config.age.secrets."users/alarsyo-hashed-password".path;
    isNormalUser = true;
    extraGroups = [
      "media"
      "networkmanager"
      "video" # for `light` permissions
      "docker"
      "wheel" # Enable ‘sudo’ for the user.
      "libvirtd"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMbf1C55Hgprm4Y7iNHae2UhZbLa6SNeurDTOyq2tr1G alarsyo@yubikey"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3rrF3VSWI4n4cpguvlmLAaU3uftuX4AVV/39S/8GO9 alarsyo@thinkpad"
    ];
  };
}
