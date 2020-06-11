selfPkgs: superPkgs: let pkgs = superPkgs; in
pkgs.lib.defineLuaPackageOverrides pkgs (
let
  generatedPackages = pkgs.callPackage ./generated-packages.nix { };
  overridePackages = self: super: let
    callPackage = super.callPackage;
    inherit (super) luaOlder luaAtLeast isLuaJIT;
  in with self; {
    /* Bespoke packages */
    cparser = callPackage ./cparser.nix { };
    effil = callPackage ./effil.nix { };
    # lunadoc = callPackage ./lunadoc.nix {
    #   inherit (self) moonscript lua-discount etlua loadkit shim-getpw;
    #   inherit (pkgs) writeText;
    # };


    earthshine = callPackage ./earthshine.nix {
    };
    facade-nvim = callPackage ./facade.nvim.nix {
      inherit (self) earthshine;
    };
    moonpick-vim = callPackage ./moonpick-vim.nix {
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
      src = pkgs.fetchFromGitHub {
        owner = "Shados"; repo = "lcmark";
        rev = "local-changes";
        sha256 = "1zkaj30mmah71v296sfs61a9jb3g1s3rc0d6sg9kcdck4hwlvaai";
      };
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
      src = pkgs.fetchFromGitHub {
        owner = "Shados"; repo = "LDoc";
        rev = "50d268a2387597c813fea6b060c5d08742dcf58a";
        sha256 = "1ji85nqjgdzr2p00a7hkxwg1bckixaqrsxxc3rq76giwaf8s16q9";
      };
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
      src = pkgs.fetchFromGitHub {
        owner = "Shados"; repo = "moonscript";
        rev = "623bb0fc5d0d23c05caf0c8ffded6ef751baf366";
        sha256 = "05kpl9l1311lgjrfghnqnh6m3zkwp09gww056bf30fbvhlfc8iyw";
      };
      knownRockspec = with super.moonscript; "${pname}-dev-1.rockspec";
      propagatedBuildInputs = with self; [
        lua lpeg luafilesystem argparse
      ];
      doCheck = true;
      checkInputs = with self; [
        busted loadkit
      ];
      checkPhase = ''
        export LUA_PATH="''${LUA_PATH:+''${LUA_PATH};}$NIX_LUA_PATH"
        export LUA_CPATH="''${LUA_CPATH:+''${LUA_CPATH};}$NIX_LUA_CPATH"
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
