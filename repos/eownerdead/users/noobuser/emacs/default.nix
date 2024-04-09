{ pkgs, lib, config, ... }:
let
  fromUsePackage = epkgs: initEl:
    [ epkgs.use-package ] ++ map (name: epkgs.${name}) (builtins.fromJSON
      (builtins.readFile (pkgs.runCommand "from-use-package" {
        nativeBuildInputs = with pkgs;
          [ (emacs-gtk.pkgs.emacsWithPackages (epkgs: [ epkgs.use-package ])) ];
      } "emacs --script ${./use-package-list.el} ${initEl} > $out || true")));
in {
  home = {
    packages = with pkgs; [ emacs-all-the-icons-fonts ];
    keyboard.options = [ "ctrl:nocaps" ];
    # https://github.com/ch11ng/exwm/issues/822
    sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-gtk3;
    extraConfig = builtins.readFile ./init.el;
    extraPackages = epkgs:
      (fromUsePackage epkgs ./init.el) ++ (with epkgs; [
        treesit-grammars.with-all-grammars
        pkgs.my.emacsPackages.eglot-tempel
        epkgs.llvm-mode
        epkgs.exwm
      ]);
  };

  services = {
    emacs = {
      enable = true;
      client.enable = true;
      defaultEditor = true;
    };
    picom = {
      enable = true;
      backend = "glx";
      vSync = true;
    };
  };

  xsession = {
    enable = true;
    numlock.enable = true;
    windowManager.command =
      "${config.programs.emacs.finalPackage}/bin/emacs -f exwm-enable";
  };

  xdg.enable = true;

  home = {
    pointerCursor = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      gtk.enable = true;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
    };
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc fcitx5-gtk libsForQt5.fcitx5-qt ];
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
    platformTheme = "gnome";
    style = {
      package = pkgs.adwaita-qt;
      name = "adwaita";
    };
  };
}

