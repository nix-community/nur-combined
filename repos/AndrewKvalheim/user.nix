{ lib, ... }:

let
  inherit (lib) mkOption;
  inherit (lib.types) attrsOf bool commas int nullOr oneOf path str submodule;

  identity = import ./library/identity.lib.nix { inherit lib; };
  system = import <nixpkgs/nixos> { };
in
{
  # Workaround for https://github.com/nix-community/home-manager/issues/2333#issuecomment-1242564101
  disabledModules = [ "config/i18n.nix" ];

  imports = [
    ./components/applications.user.nix
    ./components/browser.user.nix
    ./components/desktop.user.nix
    ./components/display.user.nix
    ./components/editor.user.nix
    ./components/fonts.user.nix
    ./components/git.user.nix
    ./components/keyboard.user.nix
    ./components/llm.user.nix
    ./components/mail.user.nix
    ./components/nix.user.nix
    ./components/openpgp.user.nix
    ./components/shell.user.nix
    ./components/spelling.user.nix
    ./components/terminal.user.nix
    ./components/unison.user.nix
    ./components/updates.user.nix
  ];

  options = {
    host = {
      dir = mkOption { type = path; };
      firefox = mkOption {
        type = submodule {
          options = {
            profile = mkOption { type = str; };
            settings = mkOption {
              type = submodule {
                freeformType = attrsOf (nullOr (oneOf [ bool int str ]));
                options = {
                  "network.trr.excluded-domains" = mkOption { type = nullOr commas; default = null; };
                };
              };
            };
          };
        };
      };
    };
    system = system.options;
  };

  config = {
    # Home manager
    programs.home-manager.enable = true;
    manual.html.enable = true;

    # User
    home.username = identity.username;
    home.homeDirectory = "/home/${identity.username}";
    home.file.".face".source = identity.image;
  };
}
