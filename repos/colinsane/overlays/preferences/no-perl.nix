self: super: {
  alacritty = super.alacritty.override {
    xdg-utils = self.xdg-open;  #< it only uses xdg-open
  };

  alacritty-graphics = super.alacritty-graphics.override {
    xdg-utils = self.xdg-open;  #< it only uses xdg-open
  };

  alpaca = super.alpaca.override {
    xdg-utils = self.emptyDirectory;  #< not actually used
  };

  blueman = super.blueman.override {
    # applet/TransferService.py uses xdg-open
    # applet/GameControllerWakelock.py uses xdg-screensaver
    xdg-utils = self.xdg-open;
  };

  brave = (super.brave.override {
    xdg-utils = self.emptyDirectory;
  }).overrideAttrs (upstream: {
    # like google-chrome, brave vendors xdg-mime and xdg-settings.
    # unlike google-chrome, the nix package physically overwrites them
    # (in addition to adding xdg-utiuls to PATH!)
    installPhase = self.lib.replaceStrings
      [
        "ln -sf ${self.emptyDirectory}"
      ]
      [ "# not patching xdg-utils" ]
      upstream.installPhase;
  });

  gpodder = super.gpodder.override {
    xdg-utils = self.xdg-open;  #< it only uses xdg-open
  };

  google-chrome = super.google-chrome.override {
    # google-chrome vendors `xdg-mime` and `xdg-settings` as fallback for when the OS doesn't provide them.
    # so, disable nixpkgs xdg-utils & use chrome's vendored versions:
    # this avoids having to build any perl and failing to cross compile.
    xdg-utils = null;
  };

  losslesscut-bin = super.losslesscut-bin.override {
    # appimageTools.wrapType2 adds default `targetPkgs` to the environment;
    # remove default packages which are unused and might otherwise cause problems
    inherit (self.extend (_: super': {
      # appimageTools = super'.appimageTools.override {
      pkgs = super'.pkgs // {
          xdg-utils = null;  #< not used
          # which = null;  #< not used
      };
      # };
    })) callPackage;
  };

  slack = super.slack.override {
    # appimageTools.wrapType2 adds default `targetPkgs` to the environment;
    # remove default packages which are unused and might otherwise cause problems
    inherit (self.extend (_self': _super': {
      # slack has strings for xdg-email, xdg-mime, xdg-open, xdg-settings, but it's not human-readable.
      # it also has strings for:
      # - org.freedesktop.portal.{Desktop,FileChooser,OpenURI,Session,Settings}
      # - gtk-open
      # - internal/mime
      # it seems largely based off chromium;
      # the only reference to "xdg-utils" in slack's .deb distribution is in:
      # - usr/lib/slack/resources/LICENSES.chromium.html
      #
      # the nixpkgs slack explicitly adds xdg-utils onto PATH (as suffix) with comment:
      # > Make xdg-open overrideable at runtime.
      #
      # let's just *try* patching out all xdg-utils except for xdg-open.
      # maybe it doesn't even need xdg-open, but it's liable to pick that up from the env if we don't specify it here.
      xdg-utils = self.xdg-open;
      # xdg-utils = self.emptyDirectory;
      # xdg-utils = self.symlinkJoin {
      #   name = "slack-xdg-utils-deps";
      #   paths = [
      #     # only these xdg-utils are used
      #     self.xdg-email
      #     self.xdg-mime
      #     self.xdg-open
      #     self.xdg-settings
      #   ];
      # };
    })) callPackage;
  };

  steam = super.steam.override {
    # appimageTools.wrapType2 adds default `targetPkgs` to the environment;
    # remove default packages which are unused and might otherwise cause problems
    buildFHSEnv = self.buildFHSEnv.override {
      inherit (self.extend (self': super': {
        pkgs = super'.pkgs // {
          xdg-utils = self.xdg-open;
          # xdg-utils = self.symlinkJoin {
          #   name = "steam-xdg-utils-deps";
          #   paths = [
          #     # only these xdg-utils are used
          #     self.xdg-open
          #     # xdg-settings is used only to check the default-web-browser, which immediately gets overriden
          #     # by `$BROWSER` env var. so just don't pass xdg-settings.
          #     # self.xdg-settings
          #   ];
          # };
          # which = null;  #< unsure if used
        };
      })) callPackage;
    };
  };

  wl-clipboard = super.wl-clipboard.override {
    xdg-utils = self.xdg-mime;  #< it only uses xdg-mime
  };

  wrapFirefox = super.wrapFirefox.override {
    # of the xdg-utils, firefox only uses xdg-settings.
    # firefox uses xdg-settings to check/set the default-web-browser.
    # we don't need that => patch out to avoid the dependency on xdg-utils (perl).
    xdg-utils = self.emptyDirectory;
    # xdg-utils = self.xdg-settings;
  };

  wrapNeovimUnstable = super.wrapNeovimUnstable.override {
    wl-clipboard = self.wl-clipboard-rs;  #< drop-in compat; avoids xdg-mime
  };
}
