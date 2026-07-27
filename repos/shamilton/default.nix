{ system ? "${builtins.currentSystem}"
, nixosVersion ? "master"
, pkgs ? import <nixpkgs> {
  inherit system;
  overlays = if (nixosVersion == "nixpkgs-unstable") then [
    (self: super: rec {
      python3 = super.python3.override {
        packageOverrides = pself: psuper: rec {
          argon2_cffi = psuper.argon2_cffi.overrideAttrs (old: {
            propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [
              psuper.argon2-cffi-bindings
            ];
          });
        };
      };
      python3Packages = python3.pkgs;
    })
  ] else [];
}
, localUsage ? false
, gomod2nix ? null
}:
let
  lib = pkgs.lib;
  mylib = import ./lib { inherit pkgs gomod2nix; }; # functions
  # kdeApplications = pkgs.libsForQt5.kdeApplications;
  # drogonNixPkgs = import (fetchTarball {
  #   url = "https://github.com/NixOS/NixPkgs/archive/cd0fa6156f486c583988d334202946ffa4b9ebe8.tar.gz";
  #   sha256 = "003vg8gz99spbmdvff06y36icn4by2yv4kb3s1m73q5z73bb2dy7";
  # }) {};
in
pkgs.lib.traceValFn (x:
 "Nixpkgs version : ${pkgs.lib.version},
  Nixos Version : ${nixosVersion},
  Local Usage : ${if localUsage then "true" else "false"}"
)
(lib.makeExtensible (self:
{
  # The `lib`, `modules`, and `overlay` names are special

  android-platform-tools = pkgs.callPackage ./pkgs/android-platform-tools { };
  argparse = pkgs.callPackage ./pkgs/argparse { };
  briefcase = pkgs.callPackage ./pkgs/briefcase { };
  # autognirehtet = pkgs.callPackage ./pkgs/AutoGnirehtet { };
  cargo-sort-ck = with pkgs.rustPlatform; pkgs.callPackage ./pkgs/cargo-sort-ck {
    inherit buildRustPackage;
  };
  circular-import-detector = pkgs.callPackage ./pkgs/circular-import-detector { };
  chunkdrive = with pkgs.rustPlatform; pkgs.callPackage ./pkgs/chunkdrive {
    inherit buildRustPackage;
  };
  # cdc-cognitoform-result-generator = pkgs.callPackage ./pkgs/CdC-cognitoform-result-generator { };
  # chart-cli = pkgs.haskellPackages.callPackage ./pkgs/chart-cli { };
  # commix = pkgs.callPackage ./pkgs/commix { };
  compton = pkgs.callPackage ./pkgs/Compton { };
  controls-for-fake = pkgs.libsForQt5.callPackage ./pkgs/ControlsForFake  {
    inherit (self) libfake;
    FakeMicWavPlayer = self.fake-mic-wav-player;
  };
  # day-night-plasma-wallpapers = pkgs.callPackage ./pkgs/day-night-plasma-wallpapers { };
  decisive-vim = with pkgs.vimUtils; pkgs.callPackage ./pkgs/decisive {
    inherit buildVimPlugin;
  };
  fake-mic-wav-player = pkgs.libsForQt5.callPackage ./pkgs/FakeMicWavPlayer {
    inherit (self) libfake argparse;
  };
  go-pathfinder = pkgs.callPackage ./pkgs/Go-pathfinder { inherit (mylib.gomod2nix) buildGoApplication; };
  go-sdl2 = pkgs.callPackage ./pkgs/go-sdl2 { inherit (mylib.gomod2nix) buildGoApplication; };
  # graph-cli = pkgs.callPackage ./pkgs/graph-cli { };
  haste-client = pkgs.callPackage ./pkgs/haste-client { };
  indexedproperty = pkgs.callPackage ./pkgs/indexedproperty { };
  instanttee = with pkgs.rustPlatform; pkgs.callPackage ./pkgs/InstantTee {
    inherit buildRustPackage;
  };
  # kirigami-gallery = pkgs.libsForQt5.callPackage ./pkgs/KirigamiGallery { };
  # kitty-ntfy-cmd = pkgs.callPackage ./pkgs/kitty-ntfy-cmd { };
  kotlin-vim = with pkgs.vimUtils; pkgs.callPackage ./pkgs/kotlin-vim {
    inherit buildVimPlugin;
  };
  lbstanza = pkgs.callPackage ./pkgs/lbstanza {
    inherit (self) lbstanza-bin;
  };
  lbstanza-bin = pkgs.callPackage ./pkgs/lbstanza-bin { };
  libfake = pkgs.callPackage ./pkgs/FakeLib { };
  # lokalize = pkgs.libsForQt5.callPackage ./pkgs/Lokalize { };
  love3d = pkgs.callPackage ./pkgs/L-ove3D { };
  mario-sokoban = with pkgs; callPackage ./pkgs/MarioSokoban { };
  merge-keepass = pkgs.callPackage ./pkgs/merge-keepass { };
  mobiledemo = pkgs.callPackage ./pkgs/MobileDemo { };
  myxournalpp = pkgs.callPackage ./pkgs/myxournalpp { };
  MyVimConfig = pkgs.callPackage ./pkgs/MyVimConfig { };
  numworks-udev-rules = pkgs.callPackage ./pkgs/numworks-udev-rules { };
  phidget-udev-rules = pkgs.callPackage ./pkgs/phidget-udev-rules { };
  phidget22 = pkgs.callPackage ./pkgs/phidget22 { };
  pronote-timetable-fetch = pkgs.callPackage ./pkgs/pronote-timetable-fetch { };
  pyfemm = pkgs.callPackage ./pkgs/pyfemm { };
  pylint-qt = pkgs.callPackage ./pkgs/pylint-qt { };
  pymecavideo = pkgs.callPackage ./pkgs/pymecavideo {
    inherit (pkgs.qt6) qttools wrapQtAppsHook;
    inherit (pkgs.libsForQt5) qtbase;
  };

  pyvicp = pkgs.callPackage ./pkgs/pyvicp { };
  mypython = let
    shellPython = pkgs.python3;
  in (shellPython.buildEnv.override {
      extraLibs = with shellPython.pkgs; [
        pandas
        numpy
        matplotlib
        scipy
      ];
    }).overrideAttrs (old: {
      name = "${shellPython.name}-mypython";
    });
  qcoro = pkgs.libsForQt5.callPackage ./pkgs/qcoro { };
  qrup = pkgs.callPackage ./pkgs/qrup { };
  renrot = pkgs.callPackage ./pkgs/renrot { };
  rpi-fan = pkgs.callPackage ./pkgs/rpi-fan { };
    # rpi-fan-serve = let
    # patchedDrogon = pkgs.drogon;
    # patchedDrogon = with drogonNixPkgs; drogon.overrideAttrs (old: {
    #   patches = (old.patches or []) ++ [
    #     (fetchpatch {
    #       url = "https://github.com/drogonframework/drogon/pull/1094/commits/52c4dcc1bda865a924a112249fd845ac5ea9c9a7.patch";
    #       sha256 = "09rbh31lwmkv8pjysvd11vz9qnrmga7iw9jn3f9i39q0y1yvrfw6";
    #     })
    #   ];
    # });
    # patchedMeson = pkgs.meson;
    # patchedMeson = with pkgs; meson.overrideAttrs (old: rec {
    #   pname = "patched-meson";
    #   version = "0.58.1";
    #   name = "${pname}-${version}";
    #   src = python3Packages.fetchPypi {
    #     inherit (old) pname;
    #     inherit version;
    #     sha256 = "0padn0ykwz8azqiwkhi8p97bl742y8lsjbv0wpqpkkrgcvda6i1i";
    #   };
    # });
  # in pkgs.libsForQt5.callPackage ./pkgs/rpi-fan-serve {
  #   inherit (self) argparse;
  #   drogon = patchedDrogon;
  #   meson = patchedMeson;
  # };
  # qradiopredict = pkgs.libsForQt5.callPackage ./pkgs/qradiopredict { };
  rswaveform = pkgs.callPackage ./pkgs/RsWaveform { inherit (self) indexedproperty; };
  rush = pkgs.callPackage ./pkgs/Rush { };
  scim = with pkgs; callPackage ./pkgs/scim { };
  labyrinthe = with pkgs; callPackage ./pkgs/Labyrinthe { };
  libphidget = with pkgs; callPackage ./pkgs/libphidget { };
  scottapps = with pkgs; callPackage ./pkgs/ScottApps { };
  scripts = with pkgs; callPackage ./pkgs/Scripts {
    eom = mate.eom;
    inherit (self) merge-keepass;
  };
  slick-greeter = with pkgs; pkgs.callPackage ./pkgs/slick-greeter ({
    inherit (gnome3) slick-greeter;
    inherit (cinnamon) xapps;
  } // (if nixosVersion == "master" then {
    inherit (gnome3) gnome-common;
  } else {  }));
  smtprelay = pkgs.callPackage ./pkgs/smtprelay { inherit (pkgs) buildGoModule; };
  # spectacle-clipboard = pkgs.libsForQt5.callPackage ./pkgs/spectacle-clipboard { };
  splat = pkgs.callPackage ./pkgs/splat { };
  sync-database = pkgs.callPackage ./pkgs/sync-database {
    inherit (self) merge-keepass;
  };
  tfk-api-unoconv = pkgs.callPackage ./pkgs/tfk-api-unoconv {
    inherit nixosVersion;
    nodejs = pkgs."nodejs-18_x";
  };
  tg = pkgs.callPackage ./pkgs/tg  { };
  typst-fillable = pkgs.callPackage ./pkgs/typst-fillable { };
  unoconvui = with pkgs.libsForQt5; callPackage ./pkgs/UnoconvUI  {
    inherit qmake qtbase qttools qtquickcontrols2;
  };
  vim-async = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-async {
    inherit buildVimPlugin;
  };
  vim-asyncomplete = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-asyncomplete {
    inherit buildVimPlugin;
  };
  vim-asyncomplete-lsp = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-asyncomplete-lsp {
    inherit buildVimPlugin;
  };
  vim-lsp = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-lsp {
    inherit (self) vim-async;
    inherit buildVimPlugin;
  };
  vim-lsp-settings = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-lsp-settings {
    inherit (self) vim-async vim-lsp vim-asyncomplete vim-asyncomplete-lsp;
    inherit buildVimPlugin;
  };
  vim-myftplugins = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-myftplugins {
    inherit buildVimPlugin;
  };
  vim-stanza = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-stanza {
    inherit buildVimPlugin;
  };
  vim-super-retab = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-super-retab {
    inherit buildVimPlugin;
  };
  vim-vala = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-vala {
    inherit buildVimPlugin;
  };
  voacap = pkgs.callPackage ./pkgs/voacap { };
  wavetrace = with pkgs; python3Packages.callPackage ./pkgs/Wavetrace {
    inherit (self) splat;
  };
  xmltoman = pkgs.callPackage ./pkgs/xmltoman { };
} // 
# Override derivations (patches),
# I put them here so that they get evaluated
# by the CI, it's also convenient to be able
# to access them directly from the root attribute
rec {
  patched-rofi = with pkgs; import ./pkgs/patched-rofi {
    inherit rofi-unwrapped nixosVersion;
  };
  patched-tabbed = with pkgs; import ./pkgs/patched-tabbed {
    inherit tabbed fetchFromGitHub libbsd zeromq nix-gitignore;
  };
  patched-alacritty = with pkgs; import ./pkgs/patched-alacritty {
    inherit
      lib
      stdenvNoCC
      fetchFromGitHub
      alacritty
      nix-gitignore
      writeScriptBin
      nixosVersion
      expat
      fontconfig
      freetype
      libGL
      wayland
      libxkbcommon
      patched-tabbed
      zeromq;
    inherit (xorg)
      libX11
      libXcursor
      libXi
      libXrandr
      libXxf86vm
      libxcb;
  };
  pyzo = pkgs.callPackage ./pkgs/pyzo {
    shellPython = self.mypython;
    python3 = pkgs.python311;
    python3Packages = pkgs.python311Packages;
  };
} //
# Derivations not supported on NUR
pkgs.lib.optionalAttrs (localUsage) (rec {
  mvn2nix = pkgs.callPackage ./pkgs/mvn2nix { };
  nixgl = pkgs.callPackage ./pkgs/nixgl { };
  xtreme-download-manager = pkgs.callPackage ./pkgs/xtreme-download-manager {
    inherit mvn2nix localUsage;
  };
})
)).extend (self: super: rec {
  modules = import ./modules { selfnur = self; };
  overlays = import ./overlays { selfnur = self; }; # nixpkgs overlays
  tests = import ./tests {
    inherit modules;
    selfnur = self;
  };
})
