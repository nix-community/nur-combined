# borrows from:
# - default config: <https://github.com/cspeterson/splatmoji/blob/master/splatmoji.config>
# - wayland: <https://github.com/cspeterson/splatmoji/issues/32#issuecomment-830862566>
{ lib, pkgs, ... }:

{
  sane.programs.splatmoji = {
    packageUnwrapped = pkgs.splatmoji.overrideAttrs (upstream: {
      nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
        pkgs.copyDesktopItems
      ];
      desktopItems = (upstream.desktopItems or []) ++ [
        (pkgs.makeDesktopItem {
          name = "splatmoji";
          exec = "splatmoji -s medium-light type";
          desktopName = "Splatmoji Emoji Picker";
        })
      ];
    });
    sandbox.whitelistWayland = true;  # it calls into a dmenu helper
    sandbox.extraHomePaths = [
      ".cache/rofi"
      ".config/rofi/config.rasi"
    ];

    suggestedPrograms = [ "rofi" ];

    persist.byStore.plaintext = [ ".local/state/splatmoji" ];
    fs.".config/splatmoji/splatmoji.config".symlink.text = ''
      # XXX doesn't seem to understand ~ as shorthand for `$HOME`
      history_file=/home/colin/.local/state/splatmoji/history
      history_length=5
      # XXX: hardcode the package paths here. all these packages are sandboxed identically
      # to `splatmoji` itself, so there's zero benefit to acquiring them via the environment;
      # doing so would in fact be costlier.
      paste_command=${lib.getExe pkgs.wtype} -M Ctrl -k v
      xdotool_command=${lib.getExe pkgs.wtype}
      xsel_command=${lib.getExe' pkgs.findutils "xargs"} ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
    '';
    # alternative tweaks:
    # rofi_command=${pkgs.wofi}/bin/wofi --dmenu --insensitive --cache-file /dev/null
    # rofi_command=${pkgs.fuzzel}/bin/fuzzel -d -i -w 60
  };
}
