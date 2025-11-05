# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  inputs,
  pkgs,
}:
let
  lib = pkgs.lib.overrideExisting pkgs.lib {
    maintainers = pkgs.lib.maintainers // {
      auscyber = "auscyber";
    };
  };
  sources = pkgs.callPackage ./_sources/generated.nix { };
  system = pkgs.stdenv.hostPlatform.system;
  toolchain = (pkgs.fetchtree inputs.fenix.info).packages.${system}.minimal.toolchain;

in
lib.fix (self: {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  ghostty-bin = pkgs.callPackage ./pkgs/ghostty {
    source = sources.ghostty;
    sourceRoot = ".";
  };
  ghostty-nightly-bin = pkgs.callPackage ./pkgs/ghostty {
    isNightly = true;
    source = {
      inherit (sources.ghostty-nightly) version pname;
      src = ./_sources + "/${sources.ghostty-nightly.src.outputHash}";
    };
    sourceRoot = ".";
  };
  zen-browser = pkgs.callPackage ./pkgs/zen-browser {
    source = sources.zen;
    sourceRoot = "Zen.app";
    applicationName = "Zen";
  };
  zen-browser-twilight = pkgs.callPackage ./pkgs/zen-browser {
    source = sources.zen-twilight;
    applicationName = "Twilight";
    sourceRoot = "Twilight.app";
  };
  bartender = pkgs.callPackage ./pkgs/bartender {
    source = sources.bartender-6;
    sourceRoot = ".";
  };
  hardlink = pkgs.callPackage ./pkgs/hardlink {
  };
  yabai = pkgs.callPackage ./pkgs/yabai {
    source = sources.yabai;

  };
  desktoppr = builtins.trace "desktoppr is now in nixpkgs" pkgs.callPackage ./pkgs/desktoppr {
  };
  kanata = pkgs.kanata.overrideAttrs (oldAttrs: {

    inherit (sources.kanata) src version;
    passthru = oldAttrs.passthru // {
      darwinDriverVersion = "6.2.0";
    };
    doInstallCheck = false;
    cargoDeps = pkgs.rustPlatform.importCargoLock sources.kanata.cargoLock."Cargo.lock";
  });
  karabiner-dk = builtins.trace "karabiner-dk is now in nixpkgs" pkgs.karabiner-dk;
  kanata-vk-agent = pkgs.callPackage ./pkgs/kanata-vk-agent {
    source = sources.kanata-vk-agent;
  };
  kanata-tray = pkgs.callPackage ./pkgs/kanata-tray {
    source = sources.kanata-tray;
  };

  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
})
