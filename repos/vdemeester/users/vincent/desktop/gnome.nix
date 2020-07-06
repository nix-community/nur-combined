{ pkgs, ... }:

{
  imports = [
    # autorandr
    ./finances.nix
    ./firefox.nix
    ./next.nix
    ./gtk.nix
    ./keyboard.nix
    ./mpv.nix
    ./redshift.nix
    ./spotify.nix
  ];
  home.sessionVariables = { WEBKIT_DISABLE_COMPOSITING_MODE = 1; };
  home.packages = with pkgs; [
    gnome3.dconf-editor
    gnome3.gnome-tweak-tool
    gnome3.pomodoro
    gnome3.gnome-boxes

    gnome3.gnome-documents
    gnome3.gnome-nettool
    gnome3.gnome-power-manager
    gnome3.gnome-todo
    gnome3.gnome-tweaks
    gnome3.gnome-usage

    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.paperwm
    my.gnome-shell-extension-shell
    gnome3.gnome-shell-extensions

    pop-gtk-theme
    pop-icon-theme
    pinentry-gnome

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
