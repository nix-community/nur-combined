{ self, super, lib, ... }: let
  builders = {
    mkShellEnv = { mkShell, runtimeShell, writeText, buildPackages }: attrs: let
      inherit (buildPackages) coreutils;
      mkShellBuilder = writeText "mkshell.sh" ''
        source .attrs.sh
        out=''${outputs[out]}
        ${coreutils}/bin/mkdir -p $out/nix-support
        ${coreutils}/bin/cp .attrs.json $out/nix-support/attrs.json
        ${coreutils}/bin/cp .attrs.sh $out/nix-support/attrs.sh
      '';
      shellEnv = args: {
        name = args.pname or args.name;
        builder = runtimeShell;
        args = [ "-eu" mkShellBuilder ];
        __structuredAttrs = true;
      };
      drv = mkShell attrs;
    in if lib.isDerivation attrs
      then attrs.overrideAttrs (attrs: shellEnv attrs)
      else mkShell (attrs // shellEnv attrs);
  };
in builtins.mapAttrs (_: p: self.callPackage p { }) builders
