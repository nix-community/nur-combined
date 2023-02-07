# Seriously thankful for @tboerger for the inspiration behind this: https://github.com/tboerger/darwin-config/blob/master/profiles/modules/dock.nix
# Changed option from my.modules.dock to dockutil
# Added --relpacing to ensure existing tiles are clobbered if need be
{ pkgs, lib, config, options, ... }:

let cfg = config.dockutil;

in {
  options = with lib; {
    dockutil = {
      enable = mkEnableOption ''
        Whether to enable dock module
      '';

      entries = mkOption {
        description = ''
          Entries for the Dock
        '';
        type = with types;
          listOf (submodule {
            options = {
              path = lib.mkOption { type = str; };

              section = lib.mkOption {
                type = str;
                default = "apps";
              };

              options = lib.mkOption {
                type = str;
                default = "";
              };
            };
          });
      };
    };
  };

  config = with lib;
    mkIf cfg.enable (let
      normalize = path: if hasSuffix ".app" path then path + "/" else path;

      entryURI = path:
        "file://" + (builtins.replaceStrings [
          " "
          "!"
          ''"''
          "#"
          "$"
          "%"
          "&"
          "'"
          "("
          ")"
        ] [ "%20" "%21" "%22" "%23" "%24" "%25" "%26" "%27" "%28" "%29" ]
          (normalize path));

      wantURIs = concatMapStrings (entry: ''
        ${entryURI entry.path}
      '') cfg.entries;

      createEntries = concatMapStrings (entry: ''
        dockutil --no-restart --add '${entry.path}' --section ${entry.section} ${entry.options} --replacing ${entry.section}
      '') cfg.entries;
    in {
      environment.systemPackages = with pkgs; [ dockutil ];

      system.activationScripts.postUserActivation.text = ''
        echo >&2 "Setting up dock items..."
        haveURIs="$(dockutil --list | ${pkgs.coreutils}/bin/cut -f2)"
        if ! diff -wu <(echo -n "$haveURIs") <(echo -n '${wantURIs}') >&2; then
          echo >&2 "Resetting dock"
          dockutil --no-restart --remove all
          ${createEntries}
          killall Dock
        else
          echo >&2 "Dock is how we want it"
        fi
      '';
    });
}
