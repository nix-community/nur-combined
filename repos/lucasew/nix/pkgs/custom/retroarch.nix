{pkgs ? import <nixpkgs> {}}:
let
  fetchRetro = { repo, rev, sha256 }:
    pkgs.fetchgit {
      inherit rev sha256;
      url = "https://github.com/libretro/${repo}.git";
      fetchSubmodules = true;
    };
  libretro = pkgs.libretro // rec {
    ppsspp = pkgs.libretro.ppsspp.override {
      src = pkgs.fetchgit {
        url = "https://github.com/hrydgard/ppsspp";
        rev = "8d610a69a97a3c6197f205747d4563bad49511cd";
        sha256 = "1hrv2a4brydi3vrqm05a9cc0636jp7scy5ch6szw9m3pr645i35r";
      };
      patches = [];
    };

    dolphin = pkgs.libretro.dolphin.override {
      src = fetchRetro {
        repo = "dolphin";
        rev = "13ad7dd33b2d9ac442de890f0caafbd1a8d46c5d";
        sha256 = "0ssyiw5yknv79chlb3am2l7i8nsyi5xgwnkfg3pkxigzbm1vp392";
      };
    };
  };
  cores = let
    enabledCores = {
      inherit (libretro) beetle-snes citra dosbox mupen64plus scummvm;
    };
    values = builtins.attrValues enabledCores;
    filterFn = item: ((builtins.typeOf item) == "set") && (builtins.hasAttr "name" item);
    filtered = builtins.filter filterFn values;
    result = filtered;
  in result;
  retroarch = pkgs.retroarch.override {
    inherit cores;
  };
in pkgs.wrapRetroArch { 
  inherit retroarch;
}
