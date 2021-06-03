selfPkgs: superPkgs: let pkgs = superPkgs; in
pkgs.lib.defineLuaPackageOverrides pkgs (
let
  generatedPackages = pkgs.callPackage ./generated-packages.nix { };
  overridePackages = self: super: let
    callPackage = super.callPackage;
    inherit (super) luaOlder luaAtLeast isLuaJIT;
  pins = import ../../nix/sources.nix pkgs.path;
in
  with self; {
    /* Bespoke packages */
    cparser = callPackage ./cparser.nix {
      inherit pins;
    };
    effil = callPackage ./effil.nix { };
    # lunadoc = callPackage ./lunadoc.nix {
    #   inherit (self) moonscript lua-discount etlua loadkit shim-getpw;
    #   inherit (pkgs) writeText;
    # };


    earthshine = callPackage ./earthshine.nix {
      inherit pins;
    };
    facade-nvim = callPackage ./facade.nvim.nix {
      inherit (self) earthshine;
      inherit pins;
    };
    moonpick-vim = callPackage ./moonpick-vim.nix {
      inherit pins;
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
      src = pins.lcmark;
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
      src = pins.ldoc;
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
      src = pins.moonscript;
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
in
  pkgs.lib.composeExtensions generatedPackages overridePackages
)
