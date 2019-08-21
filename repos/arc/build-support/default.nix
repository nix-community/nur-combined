{ self, super, lib, ... }: let
  call = file: import file { inherit self super lib; };

  sourceBashArray = name: list: with self.lib; builtins.toFile "source-bash-array-${name}" ''
    ${name}=(${concatStringsSep " " (map escapeShellArg list)})
  '';

  build-support =
    (call ./wrap.nix) //
    #(call ./call.nix) //
    (call ./exec.nix) //
    (call ./curl.nix) //
    (call ./linux.nix) //
    (call ./kakoune.nix) //
    (call ./weechat.nix) //
    (call ./rust.nix) //
    (call ./misc.nix) //
    {
      inherit sourceBashArray;
      yarn2nix = if builtins.pathExists ../yarn2nix/default.nix
        then self.callPackage ../yarn2nix { }
        else if super ? yarn2nix-moretea then self.yarn2nix-moretea
        else if !(builtins.tryEval super.yarn2nix or throw "yarn2nix").success then {
          mkYarnPackage = args: self.stdenvNoCC.mkDerivation {
            name = args.name or args.pname or "yarn2nix";
            meta.broken = true;
          };
          mkYarnModules = args: self.stdenvNoCC.mkDerivation {
            name = args.name or args.pname or "yarn2nix";
            meta.broken = true;
          };
        }
        else super.yarn2nix;

      nodeEnv = self.callPackage ({ path, stdenv, python2, utillinux, runCommand, writeTextFile, nodejs, darwin }: import (path + "/pkgs/development/node-packages/node-env.nix") {
        inherit stdenv python2 utillinux runCommand writeTextFile nodejs;
        libtool = if stdenv.isDarwin then darwin.cctools else null;
      }) { };
    };
in build-support
