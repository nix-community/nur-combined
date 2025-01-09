{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkIf
    mkEnableOption
    reverseList
    concatStringsSep
    ;
  cfg = config.abszero.i18n.inputMethod.fcitx5;
in

{
  options.abszero.i18n.inputMethod.fcitx5.enable =
    mkEnableOption "next-generation input method framework";

  config = mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true; # Do not set `GTK_IM_MODULE` and `QT_IM_MODULE`
        plasma6Support = true; # Use Qt6 versions of fcitx5 packages
        addons = with pkgs; [
          fcitx5-mozc
          kdePackages.fcitx5-chinese-addons
          fcitx5-gtk
          kdePackages.fcitx5-qt
        ];
      };
    };

    environment = {
      # `XMODIFIERS` is automatically set
      sessionVariables = {
        # https://github.com/NixOS/nixpkgs/issues/129442#issuecomment-875972207
        NIX_PROFILES = "${concatStringsSep " " (reverseList config.environment.profiles)}";
        QT_IM_MODULES = "wayland;fcitx"; # For Qt6.7+
        SDL_IM_MODULE = "fcitx";
      };
      systemPackages = with pkgs; [
        fcitx5-pinyin-zhwiki
        fcitx5-pinyin-moegirl
      ];
    };
  };
}
