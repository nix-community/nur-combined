{ config, pkgs, ... }:

{



  environment.systemPackages = with pkgs; [
    neovim
  ];



  programs.zsh.enable = true;
  users.users.pim = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
  };

  users.users.pim.initialPassword = "test";

  users.users.pim.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEY25ZaYRuKUJuVuzqK4c8dKkSxN6Cd9yhbDTa/5Njmh post@pimsnel.com"
  ];

  users.users.nixosvmtest.isNormalUser = true ;
  users.users.nixosvmtest.initialPassword = "test";
  users.users.nixosvmtest.group = "nixosvmtest";
  users.groups.nixosvmtest = {};
}

