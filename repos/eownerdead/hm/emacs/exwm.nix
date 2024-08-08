{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.eownerdead.emacs.exwm.enable = lib.mkEnableOption "Enable EXWM";

  config = lib.mkIf config.eownerdead.emacs.exwm.enable {
    eownerdead.emacs.enable = true;

    programs.emacs.extraPackages = epkgs: [ epkgs.exwm ];

    home = {
      keyboard.options = [ "ctrl:nocaps" ];
      # https://github.com/ch11ng/exwm/issues/822
      sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";
    };

    services = {
      picom = {
        enable = true;
        backend = "glx";
        vSync = true;
      };
    };

    xsession = {
      enable = true;
      numlock.enable = true;
      windowManager.command = "${config.programs.emacs.finalPackage}/bin/emacsclient -c -e '(exwm-init)'";
    };

    home.file.".xinitrc".text = config.home.file.${config.xsession.scriptPath}.text;

    xdg = {
      enable = true;
      mimeApps = {
        enable = true;
        defaultApplications = lib.attrsets.genAttrs [
          "text/*"
          "inode/directory"
        ] (_: [ "emacsclient.desktop" ]);
      };
    };

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      gtk.enable = true;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
    };

    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        libsForQt5.fcitx5-qt
      ];
    };

    gtk = {
      enable = true;
      theme = {
        package = pkgs.adw-gtk3;
        name = "adw-gtk3";
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
    };
  };
}
