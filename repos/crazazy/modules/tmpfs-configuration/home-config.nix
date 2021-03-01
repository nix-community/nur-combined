{ pkgs, config, lib, ... }:
let
  sources = import ../../nix/sources.nix;
  inherit (sources) impermanence home-manager;
in
with lib;
{
  imports = [
    "${home-manager.outPath}/nixos"
  ];
  config = mkIf config.tmpfs-setup.enable {
     home-manager.users.${config.mainUser} = { pkgs,  ...}: {
       imports = [ 
         "${impermanence}/home-manager.nix" 
         ../home-configuration
       ];
       programs.home-manager.enable = true;
       home.persistence."/nix/persist/home/erik" = {
         directories = [
           ".ssh"
           ".irssi"
           ".wine"
           ".mozilla"
           "workbench"
           "Documents"
           "Pictures"
           "VirtualBox VMs"
           ".local/share/albert"
           ".local/share/Terraria"
           ".local/share/Steam"
           ".local/share/Valve Corporation"
           ".local/share/multimc"
           ".local/share/vlc"
           ".config/discord"
         ];
         files = [
           ".gitconfig"
           ".fehbg"
           ".inputrc"
           ".profile"
           ".bashrc"
         ];
       };
     };
   };
}
