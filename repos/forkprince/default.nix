{pkgs ? import <nixpkgs> {}}: rec {
  modules = import ./modules;
  overlays = import ./overlays;
  lib = import ./lib {inherit pkgs;};

  hyprcursor-bibata = lib.callPackage ./pkgs/hyprcursor-bibata {};
  hyprpanel = lib.callPackage ./pkgs/hyprpanel {};
  syslock = lib.callPackage ./pkgs/syslock {};
  nirius = lib.callPackage ./pkgs/nirius {};

  note-block-studio = lib.callPackage ./pkgs/note-block-studio {};
  re-lunatic-player = lib.callPackage ./pkgs/re-lunatic-player {};
  beeper-nightly = lib.callPackage ./pkgs/beeper-nightly {};
  app-librescore = lib.callPackage ./pkgs/app-librescore {};
  ab-download-manager = lib.callPackage ./pkgs/abdm {};
  osu-tachyon = lib.callPackage ./pkgs/osu-tachyon {};
  moonplayer = lib.callPackage ./pkgs/moonplayer {};
  equicord = lib.callPackage ./pkgs/equicord {};
  hytale = lib.callPackage ./pkgs/hytale {};
  kilo = lib.callPackage ./pkgs/kilo {};

  keka-external-helper = lib.callPackage ./pkgs/keka-external-helper {};
  bluebubbles-server = lib.callPackage ./pkgs/bluebubbles-server {};
  creality-print = lib.callPackage ./pkgs/creality-print {};
  passepartout = lib.callPackage ./pkgs/passepartout {};
  diffusionbee = lib.callPackage ./pkgs/diffusionbee {};
  redream-dev = lib.callPackage ./pkgs/redream-dev {};
  cot-editor = lib.callPackage ./pkgs/cot-editor {};
  playcover = lib.callPackage ./pkgs/playcover {};
  dropshare = lib.callPackage ./pkgs/dropshare {};
  convierto = lib.callPackage ./pkgs/convierto {};
  crossover = lib.callPackage ./pkgs/crossover {};
  open-emu = lib.callPackage ./pkgs/open-emu {};
  wg-nord = lib.callPackage ./pkgs/wg-nord {};
  roblox = lib.callPackage ./pkgs/roblox {};
  figura = lib.callPackage ./pkgs/figura {};
  achico = lib.callPackage ./pkgs/achico {};
  blip = lib.callPackage ./pkgs/blip {};
  clop = lib.callPackage ./pkgs/clop {};

  github-desktop = lib.callPackage ./pkgs/github-desktop {};
  podman-desktop = lib.callPackage ./pkgs/podman-desktop {};
  sublime-text = lib.callPackage ./pkgs/sublime-text {};
  pixelflasher = lib.callPackage ./pkgs/pixelflasher {};
  dolphin-emu = lib.callPackage ./pkgs/dolphin-emu {};
  orca-slicer = lib.callPackage ./pkgs/orca-slicer {};
  zed-editor = lib.callPackage ./pkgs/zed-editor {};
  obs-studio = lib.callPackage ./pkgs/obs-studio {};
  retroarch = lib.callPackage ./pkgs/retroarch {};
  overlayed = lib.callPackage ./pkgs/overlayed {};
  tiny-rdm = lib.callPackage ./pkgs/tiny-rdm {};
  openrct2 = lib.callPackage ./pkgs/openrct2 {};
  lmstudio = lib.callPackage ./pkgs/lmstudio {};
  ghostty = lib.callPackage ./pkgs/ghostty {};
  vscode = lib.callPackage ./pkgs/vscode {};
  heroic = lib.callPackage ./pkgs/heroic {};
  peazip = lib.callPackage ./pkgs/peazip {};
  pcsx2 = lib.callPackage ./pkgs/pcsx2 {};
  micro = lib.callPackage ./pkgs/micro {};
  steam = lib.callPackage ./pkgs/steam {};
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
  proton-dw-bin = lib.callPackage ./pkgs/proton-dw-bin {};
  proton-em-bin = lib.callPackage ./pkgs/proton-em-bin {};
  boxtron-bin = lib.callPackage ./pkgs/boxtron-bin {};

  proton-cachyos-v1-bin = lib.callPackage ./pkgs/proton-cachyos-bin {type = "v1";};
  proton-cachyos-v2-bin = lib.callPackage ./pkgs/proton-cachyos-bin {type = "v2";};
  proton-cachyos-v3-bin = lib.callPackage ./pkgs/proton-cachyos-bin {type = "v3";};
  proton-cachyos-v4-bin = lib.callPackage ./pkgs/proton-cachyos-bin {type = "v4";};
}
