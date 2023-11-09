{ pkgs }:

rec {
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

  monaspace-fonts = pkgs.callPackage ../data/fonts/monaspace/default.nix { };
  inherit (monaspace-fonts)
    monaspace
    monaspace-argon
    monaspace-krypton
    monaspace-neon
    monaspace-radon
    monaspace-xenon;

  mopidy-subidy = pkgs.callPackage ../applications/audio/mopidy/subidy.nix {
    python3Packages = pkgs.python3Packages // python3Packages;
  };

  python3Packages = pkgs.recurseIntoAttrs {
    py-sonic = pkgs.python3.pkgs.callPackage ../development/python-modules/py-sonic { };
  };

  radeon-profile-daemon = pkgs.libsForQt5.callPackage ../tools/misc/radeon-profile-daemon { };
}
