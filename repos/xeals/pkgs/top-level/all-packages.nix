{ pkgs }:

rec {
  # Alacritty with the unmerged ligature patches applied.
  alacritty-ligatures = pkgs.callPackage ../applications/terminal-emulators/alacritty-ligatures { };

  amdgpu-fan = pkgs.callPackage ../tools/misc/amdgpu-fan { };

  cardboard = pkgs.callPackage ../applications/window-managers/cardboard { };

  goModules = pkgs.recurseIntoAttrs rec {
    qt = pkgs.libsForQt512.callPackage ../development/go-modules/qt { };
  };

  # A functional Jetbrains IDE-with-plugins package set.
  jetbrains = pkgs.dontRecurseIntoAttrs rec {
    jetbrainsPluginsFor = variant: import ../top-level/jetbrains-plugins.nix {
      inherit (pkgs) lib newScope stdenv fetchzip;
      inherit variant;
    };

    pluginBuild = jetbrainsPlatforms: pkgs.callPackage ../build-support/jetbrains/plugin.nix {
      inherit jetbrains jetbrainsPlatforms;
    };

    clionPlugins = pkgs.dontRecurseIntoAttrs (jetbrainsPluginsFor pkgs.jetbrains.clion);
    ideaCommunityPlugins = pkgs.dontRecurseIntoAttrs (jetbrainsPluginsFor pkgs.jetbrains.idea-community);
    ideaUltimatePlugins = pkgs.dontRecurseIntoAttrs (jetbrainsPluginsFor pkgs.jetbrains.idea-ultimate);

    clionWithPlugins = clionPlugins.jetbrainsWithPlugins;
    ideaCommunityWithPlugins = ideaCommunityPlugins.jetbrainsWithPlugins;
    ideaUltimateWithPlugins = ideaUltimatePlugins.jetbrainsWithPlugins;
  };

  libhl = pkgs.callPackage ../development/libraries/libhl { };

  mopidy-subidy = pkgs.callPackage ../applications/audio/mopidy/subidy.nix {
    python3Packages = pkgs.python3Packages // python3Packages;
  };

  pam_gnupg = pkgs.callPackage ../os-specific/linux/pam_gnupg { };

  picom-animations = pkgs.picom.overrideAttrs (oldAttrs: {
    pname = "picom-animations";
    src = pkgs.fetchFromGitHub {
      owner = "jonaburg";
      repo = "picom";
      rev = "d718c94";
      sha256 = "165mc53ryyxn2ybkhikmk51ay3k18mvlsym3am3mgr8cpivmf2rm";
    };
  });

  polybar = pkgs.polybar.overrideAttrs (oldAttrs: {
    # Enables an extra button in formatting, indirectly allowing the use of
    # the mouse forward and backward buttons.
    patches = (oldAttrs.patches or [ ]) ++ [ ../applications/misc/polybar/9button.patch ];
  });

  psst = pkgs.callPackage ../applications/audio/psst { };

  python3Packages = pkgs.recurseIntoAttrs {
    py-sonic = pkgs.python3.pkgs.callPackage ../development/python-modules/py-sonic { };
  };

  # The one in Nixpkgs still extracts the pre-built Debian package instead
  # of building from source.
  protonmailBridgePackages = pkgs.libsForQt512.callPackage ../applications/networking/protonmail-bridge {
    inherit goModules;
  };
  protonmail-bridge = protonmailBridgePackages.protonmail-bridge;
  protonmail-bridge-headless = protonmailBridgePackages.protonmail-bridge-headless;

  radeon-profile-daemon = pkgs.libsForQt5.callPackage ../tools/misc/radeon-profile-daemon { };

  samrewritten = pkgs.callPackage ../tools/misc/samrewritten { };

  spotify-ripper = pkgs.callPackage ../tools/misc/spotify-ripper { };

  ytarchive = pkgs.callPackage ../tools/misc/ytarchive { };

  zsh-z = pkgs.callPackage ../shells/zsh/zsh-z { };
}
