{ callPackage, stdenv, pkgs, erlang, lib, util }:

with lib.attrsets;
let
  beamLib = callPackage ./lib.nix { };

  packages = self:
    let
      callPackageWithSelf = lib.callPackageWith (pkgs // self);

      annotateDep = drv: dep:
        drv.overrideAttrs (o:
          let drvName = if o ? name then o.name else "${o.pname}-${o.version}";
          in { name = "${drvName}_${dep.name}"; });
      annotateErlangInVersion = drv: annotateDep drv erlang;

      callAndAnnotate = drv: args:
        annotateErlangInVersion (callPackageWithSelf drv args);
      callAndAnnotateElixir = drv:
        { elixir }@args:
        annotateDep (callPackageWithSelf drv args) elixir;

      # Functions
      fetchHex = callPackageWithSelf ./fetch-hex.nix { };

    in rec {
      rebar3 = annotateErlangInVersion
        (callPackage ../tools/build-managers/rebar3 {
          inherit erlang fetchHex;
        });

      elixir = util.recurseIntoAttrs
        (callPackageWithSelf ../interpreters/elixir/all-versions.nix {
          inherit util annotateErlangInVersion;
          inherit erlang;
          debugInfo = true;
        });
    };

in lib.makeExtensible packages
