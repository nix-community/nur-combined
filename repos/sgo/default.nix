{ pkgs ? import <nixpkgs> {} }:
with pkgs;
rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  rakudo = callPackage ./pkgs/rakudo { nqp = nqp; };
  moarvm = callPackage ./pkgs/rakudo/moarvm.nix { };
  nqp = callPackage ./pkgs/rakudo/nqp.nix { moarvm = moarvm; };
  zef = callPackage ./pkgs/rakudo/zef.nix { rakudo = rakudo; };

  ttystatus = callPackages ./pkgs/ttystatus { };
  cliapp = callPackages ./pkgs/cliapp { };
  cmdtest = callPackages ./pkgs/cmdtest { cliapp = cliapp; ttystatus = ttystatus; };
  vmdb2 = callPackages ./pkgs/vmdb2 { cmdtest = cmdtest; };
  elgato-gchd-firmware = callPackages ./pkgs/elgato-gchd/firmware.nix {};
  elgato-gchd = callPackages ./pkgs/elgato-gchd { elgato-gchd-firmware = elgato-gchd-firmware; };

  yuma123 = callPackages ./pkgs/yuma123 { };

}

