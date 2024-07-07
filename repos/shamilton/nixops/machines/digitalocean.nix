{ hostName }:
{ pkgs, lib, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/digital-ocean-config.nix>
  ];
  virtualisation.digitalOcean.setSshKeys = false;
  networking.hostName = hostName;
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    
    permitRootLogin = "yes";
  };
  users.users."root".openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtl/XRJaZ76eky8XhIMxIVCtCeCEXu2Dh0Hwam1/Gto/w7DGdCFXTSiNEOc7cliatFMHeOdsRHGxuOWrglVC8v0NLnHcERPoLPi+qsEHN0YrNUfJM1n/StyBTCZQVuhsbyRORRV/FZ9PZlG8Edn91TPYdRU85WCTS9WP1EZ3UogIvJO7KcbBTtR+HAYgvKhkRez4wDNroaWyeAyKWUetcdETN1NjMLek4nFVDHRz+sVS1zoCTXX5vW/pHsNUQDgwnOhpJkoVdaoA+DMYVk5geaDdFgrttJzA6RVgkmZj8DgB8/OHhDAPVL6EDvkWM9GAa2iTuqlkGXjYxJaFeyNSMf scott@SCOTT-LAPTOP"
  ];
  environment.systemPackages = with pkgs; [
    file
    git
    htop
    killall
    p7zip
    screen
    vim
    wget
    curl
    dig
  ];
}
