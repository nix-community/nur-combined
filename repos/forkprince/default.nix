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

  waterfox-bin = lib.callPackage ./pkgs/waterfox-bin {};
  helium-nightly = lib.callPackage ./pkgs/helium-nightly {};

  boxtron-bin = lib.callPackage ./pkgs/boxtron-bin {};
  proton-em-bin = lib.callPackage ./pkgs/proton-em-bin {};
  proton-sarek-bin = lib.callPackage ./pkgs/proton-sarek-bin {};
  proton-ge-rtsp-bin = lib.callPackage ./pkgs/proton-ge-rtsp-bin {};

  proton-cachyos-v1-bin = lib.callPackage ./pkgs/proton-cachyos-bin {type = "v1";};
  proton-cachyos-v2-bin = lib.callPackage ./pkgs/proton-cachyos-bin {type = "v2";};
  proton-cachyos-v3-bin = lib.callPackage ./pkgs/proton-cachyos-bin {type = "v3";};
  proton-cachyos-v4-bin = lib.callPackage ./pkgs/proton-cachyos-bin {type = "v4";};
}
