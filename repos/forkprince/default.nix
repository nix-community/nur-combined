{pkgs ? import <nixpkgs> {}}: rec {
  modules = import ./modules;
  overlays = import ./overlays;
  lib = import ./lib {inherit pkgs;};

  hyprcursor-bibata = lib.callPackage ./pkgs/hyprcursor-bibata {};
  hyprpanel = lib.callPackage ./pkgs/hyprpanel {};
  syslock = lib.callPackage ./pkgs/syslock {};
  nirius = lib.callPackage ./pkgs/nirius {};

  re-lunatic-player = lib.callPackage ./pkgs/re-lunatic-player {};
  beeper-nightly = lib.callPackage ./pkgs/beeper-nightly {};
  ab-download-manager = lib.callPackage ./pkgs/abdm {};
  osu-tachyon = lib.callPackage ./pkgs/osu-tachyon {};
  moonplayer = lib.callPackage ./pkgs/moonplayer {};
  playcover = lib.callPackage ./pkgs/playcover {};

  github-desktop = lib.callPackage ./pkgs/github-desktop {};
  dolphin-emu = lib.callPackage ./pkgs/dolphin-emu {};
  obs-studio = lib.callPackage ./pkgs/obs-studio {};
  tiny-rdm = lib.callPackage ./pkgs/tiny-rdm {};
  ghostty = lib.callPackage ./pkgs/ghostty {};
  vscode = lib.callPackage ./pkgs/vscode {};
  gimp = lib.callPackage ./pkgs/gimp {};

  helium-nightly = lib.callPackage ./pkgs/helium-nightly {};
  waterfox-bin = lib.callPackage ./pkgs/waterfox-bin {};

  yaagl = lib.callPackage ./pkgs/yaagl {};
  yaagl-os = lib.callPackage ./pkgs/yaagl {region = "os";};
  yaagl-zzz = lib.callPackage ./pkgs/yaagl {game = "zzz";};
  yaagl-zzz-os = lib.callPackage ./pkgs/yaagl {
    game = "zzz";
    region = "os";
  };
  yaagl-hsr = lib.callPackage ./pkgs/yaagl {game = "hsr";};
  yaagl-hsr-os = lib.callPackage ./pkgs/yaagl {
    game = "hsr";
    region = "os";
  };

  proton-ge-rtsp-bin = lib.callPackage ./pkgs/proton-ge-rtsp-bin {};
  proton-sarek-bin = lib.callPackage ./pkgs/proton-sarek-bin {};
  proton-em-bin = lib.callPackage ./pkgs/proton-em-bin {};
  boxtron-bin = lib.callPackage ./pkgs/boxtron-bin {};

  proton-cachyos-v1-bin = lib.callPackage ./pkgs/proton-cachyos-bin {type = "v1";};
  proton-cachyos-v2-bin = lib.callPackage ./pkgs/proton-cachyos-bin {type = "v2";};
  proton-cachyos-v3-bin = lib.callPackage ./pkgs/proton-cachyos-bin {type = "v3";};
  proton-cachyos-v4-bin = lib.callPackage ./pkgs/proton-cachyos-bin {type = "v4";};
}
