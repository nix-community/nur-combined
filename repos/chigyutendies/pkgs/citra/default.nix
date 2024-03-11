{ branch
, qt6Packages
, fetchFromGitHub
, fetchurl
}:

let
  # Fetched from https://api.citra-emu.org/gamedb
  # Please make sure to update this when updating citra!
  compat-list = fetchurl {
    name = "citra-compat-list";
    url = "https://web.archive.org/web/20231111133415/https://api.citra-emu.org/gamedb";
    hash = "sha256-J+zqtWde5NgK2QROvGewtXGRAWUTNSKHNMG6iu9m1fU=";
  };
in {
  nightly = qt6Packages.callPackage ./generic.nix rec {
    pname = "citra-nightly";
    version = "8433057909752c8b23fbe0224011fda6ecab1744";

    src = fetchFromGitHub {
      owner = "PabloMK7";
      repo = "citra";
      rev = "${version}";
#      sha256 = "0l9w4i0zbafcv2s6pd1zqb11vh0i7gzwbqnzlz9al6ihwbsgbj3k";
      sha256 = "sha256-LsRBddduEehqZTwBbEkZaTqWPDywoAOAA5zGtV7Va+U=";
      fetchSubmodules = true;
    };

    inherit branch compat-list;
  };

  canary = qt6Packages.callPackage ./generic.nix rec {
    pname = "citra-canary";
    version = "8433057909752c8b23fbe0224011fda6ecab1744";

    src = fetchFromGitHub {
      owner = "PabloMK7";
      repo = "citra";
      rev = "${version}";
      sha256 = "sha256-LsRBddduEehqZTwBbEkZaTqWPDywoAOAA5zGtV7Va+U=";
#      sha256 = "1gm3ajphpzwhm3qnchsx77jyl51za8yw3r0j0h8idf9y1ilcjvi4";
      fetchSubmodules = true;
    };

    inherit branch compat-list;
  };
}.${branch}
  
