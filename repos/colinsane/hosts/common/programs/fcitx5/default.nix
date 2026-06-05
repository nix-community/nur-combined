# fcitx5 is an "input method", to e.g. allow typing CJK on qwerty.
# but i also misuse it to allow typing emoji on qwerty:
# - press `Super+backtick`
# - type something like "effort"
#   - it should be underlined, at the least
#   - if well supported (e.g. Firefox; also gtk4, alacritty on sway 1.10+), a drop-down fuzzy matcher will appear
# - press space
# - "effort" should be replaced by `(ง •̀_•́)ง`
#
## debugging
# - `fcitx5-diagnose`
#
## config/docs:
# - `fcitx5-configtool`, then check ~/.config/fcitx5 files
# - <https://fcitx-im.org/wiki/Fcitx_5>
# - <https://wiki.archlinux.org/title/Fcitx5>
#   - theming: <https://wiki.archlinux.org/title/Fcitx5#Themes_and_appearance>
# - <https://en.wikipedia.org/wiki/Fcitx>
# - wayland specifics: <https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland>
# - quickphrase (emoji): <https://fcitx-im.org/wiki/QuickPhrase>
#   - override phrases via `~/.config/fcitx/data/QuickPhrase.mb`
#   - customize bindings via `fcitx5-configtool` > addons > QuickPhrase
# - theming:
#   - nixpkgs has a few themes: `fcitx5-{material-color,nord,rose-pine}`
#   - NUR has a few themes
#   - <https://github.com/catppuccin/fcitx5>
{ ... }:
{
  sane.programs.fcitx5 = {
    # XXX(2025-10-12): `fcitx5-with-addons` is a symlinkMerge of `fcitx5`, `fcitx5-qt`, `fcitx5-gtk`;
    # but `fcitx5-qt` doesn't cross-compile, and i can't find any functional difference v.s. just base `fcitx5`,
    # without the addons.
    # packageUnwrapped = pkgs.fcitx5-with-addons.override {
    #   addons = with pkgs; [
    #     # fcitx5-mozc  # japanese input: <https://github.com/fcitx/mozc>
    #     fcitx5-gtk  # <https://github.com/fcitx/fcitx5-gtk>
    #   ];
    # };

    sandbox.wrapperType = "inplace";  #< $out/etc/xdg/Xwayland-session.d/20-fcitx refers to bins by absolute path

    sandbox.whitelistDbus.user = true;  #< TODO: reduce
    sandbox.whitelistWayland = true;  # for `fcitx5-configtool, if nothing else`
    sandbox.extraHomePaths = [
      # ".config/fcitx"
      ".config/fcitx5"
      ".local/share/fcitx5"
    ];

    fs.".config/fcitx5/conf/quickphrase.conf".symlink.text = ''
      # Choose key modifier
      Choose Modifier=None
      # Enable Spell check
      Spell=True
      FallbackSpellLanguage=en

      [TriggerKey]
      # defaults: Super+grave, Super+semicolon
      # gtk apps use ctrl+period, so super+period is a nice complement
      0=Super+grave
      1=Super+semicolon
      2=Super+period
    '';
    fs.".config/fcitx5/conf/classicui.conf".symlink.text = ''
      Theme=sane
      Font="Sans 20"
      Vertical Candidate List=True
    '';
    fs.".local/share/fcitx5/themes/sane/theme.conf".symlink.text = ''
      # i omit several keys, especially the ones which don't seem to do much.
      # for a theme which uses many more options, see:
      # - <https://github.com/catppuccin/fcitx5/blob/main/src/catppuccin-mocha/theme.conf>
      [Metadata]
      Name=sane
      ScaleWithDPI=True

      [InputPanel]
      NormalColor=#d8d8d8
      HighlightCandidateColor=#FFFFFF
      HighlightColor=#FFFFFF
      HighlightBackgroundColor=#1f5e54

      [InputPanel/Background]
      Color=#1f5e54

      [InputPanel/Highlight]
      Color=#418379

      [InputPanel/Highlight/Margin]
      Left=20
      Right=20
      Top=7
      Bottom=7

      [InputPanel/TextMargin]
      Left=20
      Right=20
      Top=6
      Bottom=6
    '';

    services.fcitx5 = {
      description = "fcitx5: input method (IME) for emoji/internationalization";
      partOf = [ "graphical-session" ];
      command = "fcitx5";
    };

    env.XMODIFIERS = "@im=fcitx";
    # setting IM_MODULE is generally not required on wayland, but can be used to override the toolkit's own dialogs with our own.
    # env.GTK_IM_MODULE = "fcitx";
    # enable if you want them:
    # env.QT_IM_MODULE = "fcitx";
    # env.QT_PLUGIN_PATH = [ "${cfg.package}/${pkgs.qt6.qtbase.qtPluginPrefix}" ];
    # env.SDL_IM_MODULE = "fcitx";
    # env.GLFW_IM_MODULE = "ibus";  # for KiTTY, as per <https://wiki.archlinux.org/title/Fcitx5#Integration>
  };
}
