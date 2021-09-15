# Example for an overlay file that adds previous versions
# of NixOS-QChem/nixpkgs to the package set. This provides
# easy access to prevoius versions of packages.
#
#
# Named subsets for previous releases.
# Note that these set are static, i.e. they can not be augmented
# anymore with further overlays.
#

self: super:

let

  # Versions are pinned to fixed hashes.
  # These are tested version that build.
  sha = {
    "2003" = { # NixOS 20.03/NixOS-QChem 20.03
      nixpkgs = "06ce0d954b659c60221ee1dda5270a083e52e681";
      NixOS-QChem = "5edf6f242cf6b231d0ffdacd706566a097a561cc";
    };
    "2009" = { # NixOS 20.09/NixOS-QChem 20.09
      nixpkgs = "47e580e291ff40bbde191e9fed35128727963b0c";
      NixOS-QChem = "674a3fb18907f1d87784ccb84dcb835d450131f0";
    };
  };

  getNixpkgs = version: import ( builtins.fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/${sha."${version}".nixpkgs}.tar.gz");

  getNixOS-QChem = version: import (builtins.fetchTarball
    "https://github.com/markuskowa/NixOS-QChem/archive/${sha."${version}".NixOS-QChem}.tar.gz");


  buildPkgs = version: getNixpkgs version {
    config = {
      # allow the build of packages with an unfree license
      allowUnfree = true;

      qchem-config = {
        # turn off CPU optimization for maximum compatibility
        optAVX = false;

        # internal URL for proprietary packages
        srcurl = "http://my-internal-server";

        # Set to true if you want override the overlay's
        # settings with environment variables
        allowEnv = false;
      };
    };

    overlays = [ (getNixOS-QChem version) ];
  };

in {
  # legacy versions
  qchem-2003 = buildPkgs "2003";
  qchem-2009 = buildPkgs "2009";
}
