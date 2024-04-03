{ pkgs, inputs, system, lib, persistentDir, config, secretsDir, ... }:
{
  nixpkgs.config.allowUnfree = true;
	programs.firefox = {
		enable = true;
    package = inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin.overrideAttrs (old: {
      NIX_CFLAGS_COMPILE = [ (old.NIX_CFLAGS_COMPILE or "") ] ++ [ "-O3" "-march=native" "-fPIC" ];
    });
    profiles.me = {
      isDefault = true;
      id = 0;
      extensions =
        with inputs.firefox-addons.packages.${system};
        with (import ./my-extensions.nix {
          inherit fetchurl lib stdenv;
          buildFirefoxXpiAddon = inputs.firefox-addons.lib.${system}.buildFirefoxXpiAddon;
        });
      [
        # from extra-firefox-extensions.nix
        adguard-adblocker
        grepper
        visionary-bold-fixed


        # to search: https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/generated-firefox-addons.nix?ref_type=heads
        # ref: https://github.com/Misterio77/nix-config/blob/main/home/misterio/features/desktop/common/firefox.nix#L5
        # ref: https://github.com/Misterio77/nix-config/blob/main/flake.nix#L66
        onetab
        bitwarden

      ];
      settings = import ./user-settings.nix {};
      extraConfig = ''
      lockPref("browser.theme.content-theme", 0)
      '';
    };
    /*
    profiles.old = {
      isDefault = false;
      id = 1;
      path = "../../old/app-data/firefox/me";
    };
    # */
    profiles.testing = {
      id = 2;
      isDefault = false;
    };

  };

  ############ persistent folders of my profile ##################
  home.file = {
    ".mozilla/firefox/me/places.sqlite" = {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink "${persistentDir}/firefox-data/places.sqlite";
      # ref: https://github.com/nix-community/home-manager/issues/676
      # - link goes into the store, and then out again.... xD
    };
    ".mozilla/firefox/me/places.sqlite-wal" = {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink "${persistentDir}/firefox-data/places.sqlite-wal";
    };

    # one tab storage path
    ".mozilla/firefox/me/storage/default/moz-extension+++e2297551-90b4-4da0-92c8-1d00cda2d080^userContextId=4294967295" = {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink "${persistentDir}/firefox-data/onetab-folder";
    };

    # bitwarden storage path
    # makes bitwarden keep loading forever
    /*
    ".mozilla/firefox/me/storage/default/moz-extension+++e563a533-4e66-4b75-bbec-176bb803d96c^userContextId=4294967295" = {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink "${secretsDir}/firefox-bitwarden-folder";
    };
    # */
  };
}
