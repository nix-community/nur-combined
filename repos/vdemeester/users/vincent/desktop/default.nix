{ pkgs, ... }:

{
  imports = [
    # autorandr
    ./finances.nix
    ./firefox.nix
    ./next.nix
    ./gtk.nix
    ./i3.nix
    ./keyboard.nix
    ./mpv.nix
    ./mpd.nix
    ./redshift.nix
    ./spotify.nix
    ./xsession.nix
  ];
  home.sessionVariables = { WEBKIT_DISABLE_COMPOSITING_MODE = 1; };
  home.packages = with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.fr
    hunspell
    hunspellDicts.en_US-large
    hunspellDicts.en_GB-ize
    hunspellDicts.fr-any
    wmctrl
    xclip
    xdg-user-dirs
    xdg_utils
    xsel
    # TODO make this an option
    slack
    # FIXME move this elsewhere
    keybase
    pass
    profile-sync-daemon
  ];

  home.file.".XCompose".source = ./xorg/XCompose;
  home.file.".Xmodmap".source = ./xorg/Xmodmap;
  xdg.configFile."xorg/emoji.compose".source = ./xorg/emoji.compose;
  xdg.configFile."xorg/parens.compose".source = ./xorg/parens.compose;
  xdg.configFile."xorg/modletters.compose".source = ./xorg/modletters.compose;

  xdg.configFile."nr/desktop" = {
    text = builtins.toJSON [
      { cmd = "peek"; }
      { cmd = "shutter"; }
      { cmd = "station"; }
      { cmd = "dmenu"; }
      { cmd = "sxiv"; }
      { cmd = "screenkey"; }
      { cmd = "gimp"; }
      { cmd = "update-desktop-database"; pkg = "desktop-file-utils"; chan = "unstable"; }
      { cmd = "lgogdownloader"; chan = "unstable"; }
      { cmd = "xev"; pkg = "xorg.xev"; }
    ];
    onChange = "${pkgs.my.nr}/bin/nr desktop";
  };
}
