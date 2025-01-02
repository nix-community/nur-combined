{ lib, pkgs, ... }:
# notable bemenu options:
#   - see `bemenu --help` for all
#   -P, --prefix          text to show before highlighted item.
#   --scrollbar           display scrollbar. (none (default), always, autohide)
#   -H, --line-height     defines the height to make each menu line (0 = default height). (wx)
#   -M, --margin          defines the empty space on either side of the menu. (wx)
#   -W, --width-factor    defines the relative width factor of the menu (from 0 to 1). (wx)
#   -B, --border          defines the width of the border in pixels around the menu. (wx)
#   -R  --border-radius   defines the radius of the border around the menu (0 = no curved borders).
#   --ch                  defines the height of the cursor (0 = scales with line height). (wx)
#   --cw                  defines the width of the cursor. (wx)
#   --hp                  defines the horizontal padding for the entries in single line mode. (wx)
#   --fn                  defines the font to be used ('name [size]'). (wx)
#   --tb                  defines the title background color. (wx)
#   --tf                  defines the title foreground color. (wx)
#   --fb                  defines the filter background color. (wx)
#   --ff                  defines the filter foreground color. (wx)
#   --nb                  defines the normal background color. (wx)
#   --nf                  defines the normal foreground color. (wx)
#   --hb                  defines the highlighted background color. (wx)
#   --hf                  defines the highlighted foreground color. (wx)
#   --fbb                 defines the feedback background color. (wx)
#   --fbf                 defines the feedback foreground color. (wx)
#   --sb                  defines the selected background color. (wx)
#   --sf                  defines the selected foreground color. (wx)
#   --ab                  defines the alternating background color. (wx)
#   --af                  defines the alternating foreground color. (wx)
#   --scb                 defines the scrollbar background color. (wx)
#   --scf                 defines the scrollbar foreground color. (wx)
#   --bdr                 defines the border color. (wx)
#
# colors are specified as `#RRGGBB`
# defaults:
# --ab "#222222"
# --af "#bbbbbb"
# --bdr "#005577"
# --border 3
# --cb "#222222"
# --center
# --cf "#bbbbbb"
# --fb "#222222"
# --fbb "#eeeeee"
# --fbf "#222222"
# --ff "#bbbbbb"
# --fixed-height
# --fn 'Sxmo 14'
# --hb "#005577"
# --hf "#eeeeee"
# --line-height 20
# --list 16
# --margin 40
# --nb "#222222"
# --nf "#bbbbbb"
# --no-overlap
# --no-spacing
# --sb "#323232"
# --scb "#005577"
# --scf "#eeeeee"
# --scrollbar autohide
# --tb "#005577"
# --tf "#eeeeee"
# --wrap
let
  bg = "#1d1721";       # slight purple
  fg0 = "#d8d8d8";      # inactive text (light grey)
  fg1 = "#ffffff";      # active text   (white)
  accent0 = "#1f5e54";  # darker but saturated teal
  accent1 = "#418379";  # teal (matches nixos-bg)
  accent2 = "#5b938a";  # brighter but muted teal
  bemenuArgs = [
    "--wrap --scrollbar autohide --fixed-height"
    "--center --margin 45"
    "--no-spacing"
    # XXX: font size doesn't seem to take effect (would prefer larger)
    "--fn 'monospace 14' --line-height 22 --border 3"
    "--bdr '${accent0}'"                     # border
    "--scf '${accent2}' --scb '${accent0}'"  # scrollbar
    "--tb '${accent0}' --tf '${fg0}'"        # title
    "--fb '${accent0}' --ff '${fg1}'"        # filter (i.e. text that's been entered)
    "--hb '${accent1}' --hf '${fg1}'"        # selected item
    "--nb '${bg}' --nf '${fg0}'"             # normal lines (even)
    "--ab '${bg}' --af '${fg0}'"             # alternated lines (odd)
    "--cf '${accent0}' --cb '${accent0}'"    # cursor (not very useful)
  ];
  bemenuOpts = lib.concatStringsSep " " bemenuArgs;
in
{
  sane.programs.bemenu = {
    sandbox.whitelistWayland = true;

    packageUnwrapped = pkgs.bemenu.overrideAttrs (upstream: {
      nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
        pkgs.makeBinaryWrapper
      ];
      # can alternatively be specified as CLI flags
      postInstall = (upstream.postInstall or "") + ''
        wrapProgram $out/bin/bemenu \
          --set BEMENU_OPTS "${bemenuOpts}"
        wrapProgram $out/bin/bemenu-run \
          --set BEMENU_OPTS "${bemenuOpts}"
      '';
    });
  };
}
