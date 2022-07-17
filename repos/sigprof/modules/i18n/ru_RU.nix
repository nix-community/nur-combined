# Configuration for the `ru_RU.UTF-8` locale, including some personal
# preferences.
#
{
  flake,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkPackageOption mkIf;
  cfg = config.sigprof.i18n.ru_RU;

  # The Terminus font is used for both the text (or framebuffer) console and
  # the GRUB 2 bootloader.  Currently this is not changeable as an option,
  # because the code expect specific file names in the package, so it's not
  # really possible to replace Terminus with something else.
  terminus_font = flake.self.packages.${pkgs.system}.terminus-font-custom;
in {
  options.sigprof.i18n.ru_RU = {
    enable = mkEnableOption "custom configuration for the ru_RU locale";
  };

  config = mkIf cfg.enable {
    # Set the default system locale.
    i18n.defaultLocale = "ru_RU.UTF-8";

    # Set the console keymap and font.
    console.keyMap = "ruwin_cplk-UTF-8";
    console.font = lib.mkMerge [
      (lib.mkOverride 600 "${terminus_font}/share/consolefonts/ter-c16n.psf.gz")
      (lib.mkIf config.hardware.video.hidpi.enable
        (lib.mkOverride 500 "${terminus_font}/share/consolefonts/ter-c32n.psf.gz"))
    ];

    # Set the font for GRUB.
    boot.loader.grub.font = lib.mkMerge [
      (lib.mkOverride 600 "${terminus_font}/share/fonts/terminus/ter-x16n.pcf.gz")
      (lib.mkIf config.hardware.video.hidpi.enable
        (lib.mkOverride 500 "${terminus_font}/share/fonts/terminus/ter-x32n.pcf.gz"))
    ];
    boot.loader.grub.fontSize = lib.mkMerge [
      (lib.mkOverride 600 16)
      (lib.mkIf config.hardware.video.hidpi.enable
        (lib.mkOverride 500 32))
    ];

    # Configure the X11 keymap.
    services.xserver = mkIf config.services.xserver.enable {
      layout = "us,ru";
      xkbOptions = "grp:shift_caps_switch,lv3:ralt_switch,grp_led:scroll,keypad:oss,kpdl:kposs,compose:menu,misc:typo,nbsp:level3n,shift:both_capslock";
    };
  };
}
