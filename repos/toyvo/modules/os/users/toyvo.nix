{
  config,
  lib,
  pkgs,
  homelab,
  ...
}:
let
  cfg = config.userPresets;
  homePath = if pkgs.stdenv.isDarwin then "/Users" else "/home";
  enableGui = config.profiles.gui.enable or false;
in
{
  options.userPresets = {
    toyvo = {
      enable = lib.mkEnableOption "toyvo user";
      name = lib.mkOption {
        type = lib.types.str;
        default = "toyvo";
      };
    };
  };

  config = lib.mkIf cfg.toyvo.enable {
    sops.secrets.toyvo_hashed_password.neededForUsers = true;
    users = {
      users = {
        ${cfg.toyvo.name} = (
          lib.mkMerge [
            {
              name = cfg.toyvo.name;
              description = "Collin Diekvoss";
              home = "${homePath}/${cfg.toyvo.name}";
              shell = pkgs.fish;
              openssh.authorizedKeys.keys = [
                homelab.publicKeys."ssh_toyvo_auth_ed25519.pub"
                homelab.publicKeys."yubikey_usbc_ed25519_sk.pub"
                homelab.publicKeys."yubikey_usba_ed25519_sk.pub"
              ];
            }
            (lib.mkIf pkgs.stdenv.isLinux {
              isNormalUser = true;
              extraGroups = [
                "networkmanager"
                "wheel"
                "input"
                "uinput"
                cfg.toyvo.name
              ]
              ++ lib.optionals config.containerPresets.podman.enable [ "podman" ];
              hashedPasswordFile = config.sops.secrets.toyvo_hashed_password.path;
            })
          ]
        );
      };
      groups.${cfg.toyvo.name} = lib.mkIf pkgs.stdenv.isLinux { };
    };
    nix.settings.trusted-users = [
      cfg.toyvo.name
    ];
    home-manager.users.${cfg.toyvo.name} = {
      home.username = cfg.toyvo.name;
      home.homeDirectory = "${homePath}/${cfg.toyvo.name}";
      profiles = {
        defaults.enable = true;
        gui.enable = enableGui;
        toyvo.enable = true;
      };
    };
  };
}
