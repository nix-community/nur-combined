{ pkgs, config, lib, ... }:
let
  inherit (pkgs.sources) impermanence home-manager;
in
with lib;
{
  imports = [
    "${home-manager.outPath}/nixos"
  ];
  config = mkIf config.tmpfs-setup.enable {
     home-manager.users.${mainUser} = { pkgs,  ...}: {
       imports = [ 
         "${impermanence}/home-manager.nix" 
       ];
       programs.home-manager.enable = true;
       home.persistence."/nix/persist/home/erik" = {
         directories = [
           ".ssh"
           ".irssi"
           ".wine"
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
           ".profile"
           ".bashrc"
         ];
       };
     };
   };
}
