# FIRST-TIME SETUP:
# - disable notification sounds: hamburger menu in bottom-left -> preferences
#   - notification sounds can be handled by swaync
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.dissent;
in
{
  sane.programs.dissent = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = true;
        };
      };
    };

    packageUnwrapped = pkgs.dissent.overrideAttrs (upstream: {
      postConfigure = (upstream.postConfigure or "") + ''
        # dissent uses go-keyring to interface with the org.freedesktop.secrets provider (i.e. gnome-keyring).
        # go-keyring hardcodes `login.keyring` as the keyring to store secrets in, instead of reading `~/.local/share/keyring/default`.
        # `login.keyring` seems to be a special keyring preconfigured (by gnome-keyring) to encrypt everything to the user's password.
        # that's redundant with my fs-level encryption and makes the keyring less inspectable,
        # so patch dissent to use Default_keyring instead.
        # see:
        # - <https://github.com/diamondburned/dissent/issues/139>
        # - <https://github.com/zalando/go-keyring/issues/46>
        substituteInPlace vendor/github.com/zalando/go-keyring/secret_service/secret_service.go \
          --replace-fail '"login"' '"Default_keyring"'
      '';
    });

    suggestedPrograms = [
      "gnome-keyring"
    ];

    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  # notifications
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Music"
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];

    persist.byStore.private = [
      ".cache/dissent"
      ".config/dissent"  # empty?
    ];

    services.dissent = {
      description = "dissent Discord client";
      partOf = lib.mkIf cfg.config.autostart [ "graphical-session" ];
      command = "dissent";
    };
  };
}
