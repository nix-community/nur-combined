{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.desktop;
  dim-screen = pkgs.writeScript "dim-sreen.sh" ''
    #!${pkgs.stdenv.shell}
    export PATH=${lib.getBin pkgs.xlibs.xbacklight}/bin:$PATH
    trap "exit 0" INT TERM
    trap "kill \$(jobs -p); xbacklight -steps 1 -set $(xbacklight -get);" EXIT
    xbacklight -time 5000 -steps 400 -set 0 &
    sleep 2147483647 &
    wait
  '';
in
{
  options = {
    profiles.desktop = {
      enable = mkEnableOption "Enable desktop profile";
      lockCmd = mkOption {
        default = "-n ${dim-screen} -- ${pkgs.i3lock-color}/bin/i3lock-color -c 666666";
        description = "Lock command to use";
        type = types.str;
      };
      xsession = {
        enable = mkOption {
          default = true;
          description = "Enable xsession managed";
          type = types.bool;
        };
        i3 = mkOption {
          default = true;
          description = "Enable i3 managed window manager";
          type = types.bool;
        };
      };
    };
  };
  config = mkIf cfg.enable {
    home.sessionVariables = { WEBKIT_DISABLE_COMPOSITING_MODE = 1; };
    profiles.gpg.enable = true;
    profiles.emacs.capture = true;
    xsession = mkIf cfg.xsession.enable {
      enable = true;
      initExtra = ''
        ${pkgs.xlibs.xmodmap}/bin/xmodmap ${config.home.homeDirectory}.Xmodmap &
      '';
      pointerCursor = {
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ";
      };
    };
    home.keyboard = mkIf cfg.xsession.enable {
      layout = "fr(bepo),fr";
      variant = "oss";
      options = [ "grp:menu_toggle" "grp_led:caps" "compose:caps" ];
    };
    gtk = {
      enable = true;
      iconTheme = {
        name = "Arc";
        package = pkgs.arc-icon-theme;
      };
      theme = {
        name = "Arc";
        package = pkgs.arc-theme;
      };
    };
    services = {
      redshift = {
        enable = true;
        brightness = { day = "1"; night = "0.9"; };
        latitude = "48.3";
        longitude = "7.5";
        tray = true;
      };
    };
    home.file.".XCompose".source = ./assets/xorg/XCompose;
    home.file.".Xmodmap".source = ./assets/xorg/Xmodmap;
    xdg.configFile."xorg/emoji.compose".source = ./assets/xorg/emoji.compose;
    xdg.configFile."xorg/parens.compose".source = ./assets/xorg/parens.compose;
    xdg.configFile."xorg/modletters.compose".source = ./assets/xorg/modletters.compose;
    xdg.configFile."user-dirs.dirs".source = ./assets/xorg/user-dirs.dirs;
    xdg.configFile."nr/desktop" = {
      text = builtins.toJSON [
        { cmd = "surf"; }
        { cmd = "next"; }
        { cmd = "xclip"; }
        { cmd = "dmenu"; }
        { cmd = "sxiv"; }
        { cmd = "screenkey"; }
        { cmd = "gimp"; }
        { cmd = "virt-manager"; pkg = "virtmanager"; }
        { cmd = "update-desktop-database"; pkg = "desktop-file-utils"; chan = "unstable"; }
        { cmd = "lgogdownloader"; chan = "unstable"; }
        { cmd = "xev"; pkg = "xorg.xev"; }
      ];
      onChange = "${pkgs.my.nr}/bin/nr desktop";
    };
    programs = {
      firefox.enable = true;
    };
    profiles.i3.enable = cfg.xsession.i3;
    home.packages = with pkgs; [
      aspell
      aspellDicts.en
      aspellDicts.fr
      #etBook
      gnome3.defaultIconTheme
      gnome3.gnome_themes_standard
      keybase
      mpv
      pass
      peco
      profile-sync-daemon
      xdg-user-dirs
      xdg_utils
      xsel
    ];
  };
}
