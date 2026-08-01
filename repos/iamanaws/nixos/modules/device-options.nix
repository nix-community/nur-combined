{ lib, ... }:

with lib;
{
  options.device = {
    system = mkOption {
      type = types.str;
      default = "x86_64-linux";
      description = "Target system architecture, e.g. x86_64-linux or aarch64-linux.";
    };

    hostname = mkOption {
      type = types.str;
      default = "nixos";
      description = "Hostname for the machine.";
    };

    profile = mkOption {
      type = types.enum [
        "server"
        "laptop"
        "desktop"
        "vm"
      ];
      default = "server";
      description = "Profile of the machine (server, laptop, desktop, vm).";
    };

    users =
      let
        userSpecType = types.submodule (
          { ... }:
          {
            options = {
              name = mkOption {
                type = types.str;
                description = "Username to provision.";
              };

              groups = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = "Groups to add the user to (host-local).";
              };

              # NixOS-only in practice; ignored on Darwin by the builder.
              packages = mkOption {
                type = types.listOf types.package;
                default = [ ];
                description = "Extra packages to add to `users.users.<name>.packages` (host-local, NixOS only).";
              };

              sshKey = mkOption {
                type = types.str;
                default = "";
                description = "SSH public key for `openssh.authorizedKeys.keys`.";
              };

              homeManager = {
                enable = mkOption {
                  type = types.bool;
                  default = true;
                  description = "Whether to auto-add this user to `home-manager.users`.";
                };

                module = mkOption {
                  type = types.str;
                  default = "auto";
                  description = ''
                    Which home-manager module to import for this user.

                    Supported values:
                    - "auto" (default): prefer `home/users/<user>/nixos` (or `/darwin`) if present, else `home/users/<user>`
                    - "default": use `home/users/<user>`
                    - "nixos": use `home/users/<user>/nixos`
                    - "darwin": use `home/users/<user>/darwin`
                    - "<os>/<subpath>": e.g. "nixos/pwnbox" → `home/users/<user>/nixos/pwnbox`
                  '';
                };
              };
            };
          }
        );
      in
      mkOption {
        type = types.listOf (types.either types.str userSpecType);
        default = [ ];
        description = ''
          Users to provision on the host.

          Accepts either:
          - a string username (e.g. `"alice"`)
          - an attrset with extra metadata (e.g. `{ name = "alice"; groups = [ "wheel" "input" ]; }`)
        '';
      };

    compositors = mkOption {
      type =
        with types;
        listOf (enum [
          "gnome"
          "hyprland"
        ]);
      default = [ ];
      description = "Optional Linux graphical sessions to enable for this host.";
    };

    stateVersion = mkOption {
      type = types.str;
      default = "26.05";
      description = "System stateVersion for compatibility.";
    };

    timezone = mkOption {
      type = types.str;
      default = "UTC";
      description = "Default timezone for the host.";
    };

    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      description = "Default locale for the host.";
    };

    openpgp.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable OpenPGP smartcard support (GnuPG + hardware token tooling).
      '';
    };
  };
}
