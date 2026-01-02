{ pkgs, lib }:

rec {
  # A functional Jetbrains IDE-with-plugins package set.
  jetbrains = lib.dontRecurseIntoAttrs rec {
    jetbrainsPluginsFor = variant: import ../top-level/jetbrains-plugins.nix {
      inherit (pkgs) lib newScope stdenv fetchzip;
      inherit variant;
    };

    pluginBuild = jetbrainsPlatforms: pkgs.callPackage ../build-support/jetbrains/plugin.nix {
      inherit jetbrains jetbrainsPlatforms;
    };

    clionPlugins = lib.dontRecurseIntoAttrs (jetbrainsPluginsFor pkgs.jetbrains.clion);
    ideaCommunityPlugins = lib.dontRecurseIntoAttrs (jetbrainsPluginsFor pkgs.jetbrains.idea-community);
    ideaUltimatePlugins = lib.dontRecurseIntoAttrs (jetbrainsPluginsFor pkgs.jetbrains.idea-ultimate);

    clionWithPlugins = clionPlugins.jetbrainsWithPlugins;
    ideaCommunityWithPlugins = ideaCommunityPlugins.jetbrainsWithPlugins;
    ideaUltimateWithPlugins = ideaUltimatePlugins.jetbrainsWithPlugins;
  };

  mopidy-subidy = pkgs.callPackage ../applications/audio/mopidy/subidy.nix {
    python3Packages = pkgs.python3Packages // python3Packages;
  };

  python3Packages = lib.recurseIntoAttrs {
    py-sonic = pkgs.python3.pkgs.callPackage ../development/python-modules/py-sonic { };
  };

  radeon-profile-daemon = pkgs.libsForQt5.callPackage ../tools/misc/radeon-profile-daemon { };
}
