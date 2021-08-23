{ pkgs, config, lib, ... }:
let
  sources = import ../../nix/sources.nix;
  inherit (sources) gitignore impermanence home-manager;
  inherit (pkgs.callPackage gitignore { inherit (pkgs) lib; }) gitignoreSource;
in
with lib;
{
  imports = [
    "${home-manager.outPath}/nixos"
  ];
  config = mkIf config.tmpfs-setup.enable {
    home-manager.users.${config.mainUser} = { pkgs, ... }: {
      imports = [
        "${impermanence}/home-manager.nix"
        ../home-configuration
      ];

      programs.home-manager.enable = true;
      privateConfig.enable = true;

      home.file = mapAttrs'
        (k: v: nameValuePair (".config/${k}") {
          source = ../../local + "/${k}";
          recursive = true;
        })
        (builtins.readDir ../../local);

      home.persistence."/nix/persist/home/erik" = {
        directories = [
          ".ssh"
          ".wine"
          ".mozilla"
          "Desktop"
          "Documents"
          "Music"
          "VirtualBox VMs"
          "workbench/browsing"
          "workbench/EMACS"
          ".local/share/keybase"
          ".local/share/Steam"
          ".config/keybase"
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
