# Shared PackageList
# TODO: Strip out all gui tools into another package
let
  base = {pkgs, ...}: with pkgs; [
    tmux
    git
    gnumake
    htop
    vim
    wget
    file
    pv
    dnsutils
    ag
    lsof
    jq
    google-cloud-sdk # user
  ];


  ui = {pkgs, ...}: with pkgs; [
    # mail
    isync # user
    mu # user

    html2text # user

    deja-dup
    networkmanager
    networkmanagerapplet
    chromium # user
    xscreensaver
    udiskie
    exfat-utils
    notify-osd # user
    libnotify # user
    trayer # user
    rofi # user
    pa_applet # user
    haskellPackages.xmobar # user
    xcape # user
    xlockmore # user
    xautolock # user
    vlc # user
    quaternion # user
    weechat # user
    terminator # user
    breeze-qt5
    breeze-gtk
    pkgs.breeze-icons.out
    gnome3.adwaita-icon-theme
    hicolor_icon_theme
  ];

  f = list: {pkgs, ...}: { environment.systemPackages = list pkgs; };
in
{
  base = f base;
  ui = f ui;
}
