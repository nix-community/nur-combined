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
  enableGui = config.nixcfg.gui.enable or false;
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
    programs.fish.enable = true;
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
              ++ lib.optionals (config.virtualisation.podman.enable or false) [ "podman" ];
              initialHashedPassword = "$y$j9T$tkZ4b5vK1fCsRP0oWUb0e1$w0QbUEv9swXir33ivvM70RYTYflQszeLBi3vubYTqd8";
              uid = config.ids.uids.toyvo;
            })
          ]
        );
      };
      groups.${cfg.toyvo.name} = lib.mkIf pkgs.stdenv.isLinux {
        gid = config.ids.gids.toyvo;
      };
    };
    nix.settings.trusted-users = [
      cfg.toyvo.name
    ];
    home-manager.users.${cfg.toyvo.name} = {
      home.username = cfg.toyvo.name;
      home.homeDirectory = "${homePath}/${cfg.toyvo.name}";
      nixcfg = {
        shells.enable = true;
        tools.enable = true;
        session.enable = true;
        sops-home.enable = true;
        catppuccin-home.enable = true;
        gui.enable = enableGui;
        users.toyvo.enable = true;
      };
    };

    # NixOS activation resets home directory permissions via chmod,
    # which wipes ACLs. Restore them after the users activation script.
    system.activationScripts.fixToyVoACLs = lib.mkIf pkgs.stdenv.isLinux {
      deps = [ "users" ];
      text = ''
        ${pkgs.acl}/bin/setfacl -m u:hermes:rx ${homePath}/${cfg.toyvo.name} 2>/dev/null || true
        ${pkgs.acl}/bin/setfacl -d -m u:hermes:rx ${homePath}/${cfg.toyvo.name} 2>/dev/null || true
      '';
    };
  };
}
