selfPkgs: superPkgs: let
  pkgs = superPkgs;
  generatedLuaPackages = pkgs.callPackage ./generated-packages.nix { };
  overridenLuaPackages = self: super: let
    inherit (super) luaOlder luaAtLeast isLuaJIT;
    inherit (self) callPackage;
    pins = import ../../nix/sources.nix pkgs.path pkgs.targetPlatform.system;
  in with self; {
    /* Bespoke packages */
    cparser = callPackage ./cparser.nix {
      inherit pins;
    };
    effil = callPackage ./effil.nix { };
    # lunadoc = callPackage ./lunadoc.nix {
    #   inherit (self) moonscript lua-discount etlua loadkit shim-getpw;
    #   inherit (pkgs) lib writeText;
    # };


    earthshine = callPackage ./earthshine.nix {
      inherit pins;
      inherit (pkgs) lib;
    };
    facade-nvim = callPackage ./facade.nvim.nix {
      inherit (self) earthshine;
      inherit pins;
      inherit (pkgs) lib;
    };
    moonpick-vim = callPackage ./moonpick-vim.nix {
      inherit pins;
      inherit (pkgs) lib;
    };

    /* Overrides for generated packages */
    inotify = super.inotify.override ({
      externalDeps = with selfPkgs; [
        { name = "INOTIFY"; dep = glibc.dev; }
      ];
    });

    lcmark = super.lcmark.override (oa: let
      version' = "0.29.0";
      revision = "2";
    in rec {
      version = "${version'}-${revision}";
      # Add support for luajit & 5.1 (test this moar), and use lyaml
      src = pins.lcmark.outPath;
      disabled = luaOlder "5.1" || luaAtLeast "5.4";
      knownRockspec = let
        rockspecName = "${super.lcmark.pname}-${version'}-${revision}.rockspec";
      in pkgs.runCommand rockspecName { inherit src; } ''
        sed -e "s/_VERSION/${version'}/g; s/_REVISION/${revision}/g" \
          "$src/rockspec.in" > $out
      '';
      propagatedBuildInputs = [ lua cmark lyaml lpeg optparse ];
    });

    ldoc = super.ldoc.override ({
      src = pins.ldoc.outPath;
    });

    lua-ev = super.lua-ev.override ({
      buildInputs = with selfPkgs; [
        libev
      ];
    });

    luagraph = super.luagraph.override ({
      buildInputs = with selfPkgs; [
        graphviz libtool
      ];
    });

    lunix = super.lunix.override ({
      buildInputs = with selfPkgs; [
        glibc
      ];
        # { name = "INOTIFY"; dep = glibc; }
    });

    moonscript = super.moonscript.override ({
      src = pins.moonscript.outPath;
      knownRockspec = with super.moonscript; "${pname}-dev-1.rockspec";
      propagatedBuildInputs = with self; [
        lua lpeg luafilesystem argparse
      ];
      doCheck = true;
      checkInputs = with self; [
        busted loadkit
      ];
      checkPhase = ''
        make test $makeFlags
      '';
    });

    yaml = super.yaml.override ({
      # Patch to build consistently for 5.1-5.3 + luajit
      patches = [
        ./yaml.patch
      ];
    });
  };
in pkgs.lib.defineLuaPackageOverrides pkgs [ generatedLuaPackages overridenLuaPackages ]
