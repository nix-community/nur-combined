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
        name = args.pname or args.name or "nix-shell";
        builder = runtimeShell;
        args = [ "-eu" mkShellBuilder ];
        __structuredAttrs = true;
      };
    in if lib.isDerivation attrs
      then attrs.overrideAttrs (attrs: shellEnv attrs)
      else mkShell (attrs // shellEnv attrs);

    # replacement for `mkShell` that includes a `.shellEnv` attribute for caching the shell
    mkShell' = { mkShell, mkShellEnv }: let
    in {
      inherit mkShell mkShellEnv;
      __functionArgs = lib.functionArgs mkShell;
      __functor = self: attrs: lib.drvPassthru (drv: let
        shellEnv = self.mkShellEnv attrs;
      in {
        inherit shellEnv;
        ci = attrs.ci or { } // {
          inputs = attrs.ci.inputs or [ ] ++ [ shellEnv ];
        };
      }) (self.mkShell attrs);
    };
  };
in builders
