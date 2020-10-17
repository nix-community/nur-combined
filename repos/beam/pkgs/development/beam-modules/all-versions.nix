{ callPackage, stdenv, pkgs, erlang, lib, util, mainOnly }:

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

    in rec {
      rebar = callPackage ../tools/build-managers/rebar { inherit erlang; };

      # Caution: rebar3 built without plugins... 
      # Seems complex to resolve this issue.
      # Let's just use old-fashioned way. ie. download from website
      # rebar3 =
      #   callPackage ../tools/build-managers/rebar3 { inherit erlang fetchHex; };

      # Functions
      # fetchHex = callPackageWithSelf ./fetch-hex.nix { };
      # fetchRebar3Deps =
      #   callPackageWithSelf ./fetch-rebar-deps.nix { inherit rebar3; };
      # rebar3Relx =
      #   callPackageWithSelf ./rebar3-release.nix { inherit erlang rebar3; };

      # buildRebar3 =
      #   callPackageWithSelf ./build-rebar3.nix { inherit erlang rebar3 pc; };
      # buildHex = callPackageWithSelf ./build-hex.nix { inherit buildRebar3; };
      # buildErlangMk =
      #   callPackageWithSelf ./build-erlang-mk.nix { inherit erlang; };

      # rebar3 port compiler plugin is required by buildRebar3
      # pc = callAndAnnotate ./pc { inherit buildHex; };

      elixirs = util.recurseIntoAttrs
        (callPackageWithSelf ../interpreters/elixir/all-versions.nix {
          inherit util annotateErlangInVersion mainOnly;
          inherit rebar erlang;
          debugInfo = true;
        });

      # lfes = util.recurseIntoAttrs
      #   (callPackageWithSelf ../interpreters/lfe/all-versions.nix {
      #     inherit util beamLib annotateErlangInVersion mainOnly;
      #     inherit erlang buildRebar3 buildHex;
      #   });

      # Non hex packages. Examples how to build Rebar/Mix packages with and
      # without helper functions buildRebar3 and buildMix.
      # hex = callAndAnnotate ./hex { };
      # buildMixes = util.recurseIntoAttrs (mapAttrs (_: elixir:
      #   (callPackageWithSelf ./build-mix.nix { inherit hex elixir erlang; }))
      #   (util.filterDerivations elixirs));
      # webdriver = annotateDep
      #   ((callPackageWithSelf ./webdriver { inherit erlang; }).overrideAttrs
      #     (o: { name = "${o.name}-${o.version}"; })) erlang;
      # relxExe = callAndAnnotate ../tools/erlang/relx-exe {
      #   inherit fetchRebar3Deps rebar3Relx;
      # };

      # An example of Erlang/C++ package.
      # cuter = callAndAnnotate ../tools/erlang/cuter { inherit erlang; };
    };

  allPackages = lib.makeExtensible packages;
  # mainPackages = (with allPackages; { inherit elixirs lfes; });
  mainPackages = (with allPackages; { inherit elixirs; });

in if mainOnly then mainPackages else allPackages
