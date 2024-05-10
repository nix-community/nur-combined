{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.xdg.terminal-exec;
in
with lib;
{
  meta.maintainers = with maintainers; [ Cryolitia ];

  ###### interface

  options = {

    xdg.terminal-exec = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = mdDoc ''
          Whether to enable the proposal for XDG terminal execution utility.
        '';
      };

      config = mkOption {
        type = with lib.types; attrsOf (listOf str);
        default = { };
        description = mdDoc ''
          Configuration options for XDG terminal execution utility.

          The keys are the desktop environments, and the values are the list of teminals' [desktop file ID](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s02.html#desktop-file-id) to try.

          To define your current desktop environment, run `echo $XDG_CURRENT_DESKTOP`.

          The default value is used when the desktop environment is not found in the configuration.
        '';
        example = {
          default = [ "kitty.desktop" ];
          GNOME = [ "com.raggesilver.BlackBox.desktop" ];
        };
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [ xdg-terminal-exec ];

      etc = attrsets.mapAttrs' (
        desktop: terminals:

        # map desktop name such as GNOME to `xdg/gnome-xdg-terminals.list`, default to `xdg/xdg-terminals.list`
        attrsets.nameValuePair (
          "xdg/" + (if desktop == "default" then "" else "${strings.toLower desktop}-") + "xdg-terminals.list"
        ) { text = strings.concatLines terminals; }
      ) cfg.config;
    };
  };
}
