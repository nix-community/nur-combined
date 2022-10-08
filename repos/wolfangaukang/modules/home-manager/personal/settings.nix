{ pkgs, ... }:

let
  nur = pkgs.nur;
  nur_rycee = nur.repos.rycee;
  nur_wolfangaukang = nur.repos.wolfangaukang;
  inherit (nur_wolfangaukang) vdhcoapp multifirefox;
  inherit (nur_rycee) firefox-addons;

in rec {
  packages = {
    cli = with pkgs; [
      tree
      p7zip
    ];
    gui = with pkgs; [
      calibre
      keepassxc
      libreoffice
      qbittorrent
      raven-reader
      thunderbird
      vlc
    ];
    dev = [ pkgs.shellcheck ];
    work = with pkgs; [
      # GUI
      keybase-gui
      remmina
      signumone-ks
      upwork-download

      # CLI
      awscli2
      aws-mfa
      ssm-session-manager-plugin
    ];
    gaming = with pkgs; [ protontricks winetricks ];
    browser = [ vdhcoapp ];
    fonts = [
      (pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; })
    ];
  };

  mimelist = {
    "application/xml" = "neovim.desktop";
    "application/x-perl" = "neovim.desktop";
    "image/jpeg" = "feh.desktop";
    "image/png" = "feh.desktop";
    "text/mathml" = "neovim.desktop";
    "text/plain" = "neovim.desktop";
    "text/xml" = "neovim.desktop";
    "text/x-c++hdr" = "neovim.desktop";
    "text/x-c++src" = "neovim.desktop";
    "text/x-xsrc" = "neovim.desktop";
    "text/x-chdr" = "neovim.desktop";
    "text/x-csrc" = "neovim.desktop";
    "text/x-dtd" = "neovim.desktop";
    "text/x-java" = "neovim.desktop";
    "text/x-python" = "neovim.desktop";
    "text/x-sql" = "neovim.desktop";
    "text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;" = "neovim.desktop";
     "x-scheme-handler/http" = "firefox.desktop";
     "x-scheme-handler/https" = "firefox.desktop";
     "x-scheme-handler/about" = "firefox.desktop";
     "x-scheme-handler/unknown" = "firefox.desktop";
  };

  chromium.extensions = [
    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
    "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
    "pmcmeagblkinmogikoikkdjiligflglb" # Privacy Redirect
    "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
    "hjdoplcnndgiblooccencgcggcoihigg" # Terms of Service; Didn’t Read
  ];

  firefox = {
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      extraNativeMessagingHosts = [ vdhcoapp ];
      extraPolicies = {
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
      };
    };
    extensions = with firefox-addons; [
      auto-tab-discard
      darkreader
      decentraleyes
      disable-javascript
      https-everywhere
      privacy-badger
      privacy-redirect
      ublock-origin
    ];
    extraPkgs = packages.browser ++ [ multifirefox ];
    settings = {
      common = {
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.tabs.warnOnClose" = false;
        "extensions.pocket.enabled" = false;
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
      };
      sandbox = {
        "browser.privatebrowsing.autostart" = true;
        "browser.startup.homepage" = "about:blank";
        # https://www.eff.org/https-everywhere/set-https-default-your-browser
        "dom.security.https_only_mode" = true;
        "privacy.clearOnShutdown.cache" = true;
        "privacy.clearOnShutdown.cookies" = true;
        "privacy.clearOnShutdown.downloads" = true;
        "privacy.clearOnShutdown.formdata" = true;
        "privacy.clearOnShutdown.history" = true;
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown.openWindows" = true;
        "privacy.clearOnShutdown.sessions" = true;
        "privacy.clearOnShutdown.siteSettings" = true;
        "signon.rememberSignons" = false;
      };
    };
  };

  neovim = {
    package = pkgs.neovim-unwrapped;
    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-nixhash
    ];
  };

  vscode = {
    package = pkgs.vscodium;
    extensions = (with pkgs.vscode-extensions; [
      arrterian.nix-env-selector
      gruntfuggly.todo-tree
      hashicorp.terraform
      jnoortheen.nix-ide
      ms-python.python
      timonwong.shellcheck
      viktorqvarfordt.vscode-pitch-black-theme
      vscodevim.vim
      yzhang.markdown-all-in-one
    ]);
    # Example on how to add a extension from the marketplace
    # ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
    #   name = "vscode-pitch-black-theme";
    #   publisher = "ViktorQvarfordt";
    #   version = "1.2.4";
    #   sha256 = "sha256-HTXToZv0WWFjuQiofEJuaZNSDTmCUcZ0B3KOn+CVALw=";
    # }];

    userSettings = {
      "editor.insertSpaces" = false;
      "git.enableCommitSigning" = true;
      "keyboard.dispatch" = "keyCode";
      "python.pythonPath" = "${pkgs.python}/bin/python3";
      "redhat.telemetry.enabled" = false;
      "todo-tree.general.tags" = [ "BUG" "FIXME" "TODO" ];
      "vim.enableNeovim" = true;
      "vim.neovimPath" = "${pkgs.neovim}/bin/nvim";
      "window.zoomLevel" = -1;
      "window.restoreWindows" = "none";
      "workbench.colorTheme" = "Pitch Black";
      "[python]" = {
        "editor.insertSpaces" = true;
        "editor.tabSize" = 4;
      };
    };
  };
}
