# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

let result = pkgs.lib.makeScope pkgs.newScope (self: let
    inherit (self) callPackage;
in {
    # The `lib`, `modules`, and `overlays` names are special
    # Renamed here to avoid shadowing their builtin nixpkgs counterparts in callPackage
    myLib = import ./lib { inherit pkgs; }; # functions
    myModules = import ./modules; # NixOS modules
    myOverlays = import ./overlays; # nixpkgs overlays
    
    _Read-Me-link = pkgs.runCommandLocal "___Read_Me___" rec {
        message = ''
        This is not a real package.
        It's just here to add a Read Me link for this repo on the NUR site.
        See <${meta.homepage}> for the actual Read Me.
        Or for the local copy: ${toString ./README.md}
        '';
        meta = {
            homepage = "https://github.com/Rhys-T/nur-packages#readme";
            knownVulnerabilities = [message];
        };
    } ''
        echo -E "$message" >&2
        exit 1
    '';
    
    maintainers = import ./maintainers.nix;
    
    allegro5 = let
        needsMacPatch =
            pkgs.hostPlatform.isDarwin &&
            pkgs.lib.versionOlder pkgs.hostPlatform.darwinMinVersion "11.0" &&
            pkgs.lib.versionAtLeast pkgs.allegro5.version "5.2.10.0" &&
            pkgs.lib.versionOlder pkgs.allegro5.version "5.2.10.1"
        ;
    in pkgs.allegro5.overrideAttrs (old: {
        patches = (old.patches or []) ++ pkgs.lib.optionals needsMacPatch [
            (pkgs.fetchpatch {
                url = "https://github.com/Rhys-T/allegro5/commit/7c928e34042fd7b83d55649f240a38e937ed169b.patch";
                hash = "sha256-mLxEH3m/mFpu7tXkk8snRyLu4fQcJlcq81c/+Zi3pmM=";
            })
        ];
        meta = old.meta // {
            description = (old.meta.description or "allegro5") + " (fixed for macOS/Darwin x86_64 < 11.0)";
        };
    });
    
    lix-game-packages = callPackage ./pkgs/lix-game/packages.nix {};
    lix-game = self.lix-game-packages.game;
    lix-game-server = self.lix-game-packages.server;
    lix-game-libpng = if pkgs.hostPlatform.isDarwin then (self.lix-game-packages.overrideScope (self: super: {
        convertImagesToTrueColor = false;
    })).game else self.lix-game;
    lix-game-issue-431 = if pkgs.hostPlatform.isDarwin then (self.lix-game-packages.overrideScope (self: super: {
        convertImagesToTrueColor = false;
        disableNativeImageLoader = false;
    })).game else self.lix-game;
    lix-game-CIImage = if pkgs.hostPlatform.isDarwin then (self.lix-game-packages.overrideScope (self: super: {
        convertImagesToTrueColor = false;
        disableNativeImageLoader = "CIImage";
    })).game else self.lix-game;
    _ciOnly.lix-game = pkgs.lib.recurseIntoAttrs {
        assets = (self.lix-game-packages.overrideScope (self: super: {
            convertImagesToTrueColor = false;
        })).assets;
        assets-PNG32 = (self.lix-game-packages.overrideScope (self: super: {
            convertImagesToTrueColor = true;
        })).assets;
        inherit (self.lix-game-packages) highResTitleScreen;
    };
    
    xscorch = callPackage ./pkgs/xscorch {};
    
    pce = callPackage ./pkgs/pce {};
    pce-with-unfree-roms = self.pce.override { enableUnfreeROMs = true; };
    pce-snapshot = callPackage ./pkgs/pce/snapshot.nix {};
    
    bubbros = callPackage ./pkgs/bubbros {};
    
    flatzebra = callPackage ./pkgs/flatzebra {};
    burgerspace = callPackage ./pkgs/flatzebra/burgerspace.nix {};
    
    hfsutils = callPackage ./pkgs/hfsutils {};
    hfsutils-tk = self.hfsutils.override { enableTclTk = true; };
    
    minivmac36 = callPackage ./pkgs/minivmac/36.nix {};
    minivmac37 = callPackage ./pkgs/minivmac/37.nix {};
    minivmac = self.minivmac36;
    minivmac-unstable = self.minivmac37;
    
    minivmac-ii = self.minivmac.override { macModel = "II"; };
    minivmac-ii-unstable = self.minivmac-unstable.override { macModel = "II"; };
    
    mame = callPackage (pkgs.callPackage ./pkgs/mame {}) {};
    mame-metal = self.mame.override { darwinMinVersion = "11.0"; };
    hbmame = callPackage ./pkgs/mame/hbmame.nix {};
    hbmame-metal = self.hbmame.override { mame = self.mame-metal; };
    
    pacifi3d = callPackage ./pkgs/pacifi3d {};
    pacifi3d-mame = self.pacifi3d.override { romsFromMAME = self.mame; };
    pacifi3d-hbmame = self.pacifi3d.override { romsFromMAME = self.hbmame; };
    _ciOnly.pacifi3d-rom-xmls = pkgs.lib.recurseIntoAttrs {
        mame = self.pacifi3d-mame.romsFromXML;
        hbmame = self.pacifi3d-hbmame.romsFromXML;
    };
    
    konify = callPackage ./pkgs/konify {};
    
    asciiportal = callPackage ./pkgs/asciiportal {};
    asciiportal-git = callPackage ./pkgs/asciiportal/git.nix {};
    
    xorcurses = callPackage ./pkgs/xorcurses {};
    xorcurses-git = callPackage ./pkgs/xorcurses/git.nix {};
    
    powder = callPackage ./pkgs/powder {};
    
    xinvaders3d = callPackage ./pkgs/xinvaders3d {};
    
    icbm3d = pkgs.icbm3d.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
            substituteInPlace makefile --replace-fail 'CC=' '#CC='
            substituteInPlace randnum.c --replace-fail 'stdio.h' 'stdlib.h'
            sed -i '1i\
            #include <string.h>' text.c
        '';
        meta = old.meta // {
            description = "${old.meta.description or "icbm3d"} (fixed for macOS/Darwin)";
            platforms = old.meta.platforms ++ pkgs.lib.platforms.darwin;
        };
    });
    
    xgalagapp = pkgs.xgalagapp.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
            substituteInPlace Makefile --replace-fail 'CXX =' '#CXX ='
        '';
        meta = old.meta // {
            description = "${old.meta.description or "xgalagapp"} (fixed for macOS/Darwin)";
            platforms = old.meta.platforms ++ pkgs.lib.platforms.darwin;
        };
    });
    
    fpc = let
        inherit (pkgs) lib;
        fpcOrig = pkgs.fpc;
        needsOldClang = fpcOrig.stdenv.cc.isClang && lib.versionAtLeast fpcOrig.stdenv.cc.version "18";
        fpc = if needsOldClang then fpcOrig.override {
            inherit (pkgs.llvmPackages_17) stdenv;
        } else fpcOrig;
        needsFix =
            pkgs.hostPlatform.isDarwin && 
            !(lib.hasInfix "-syslibroot $SDKROOT" (fpc.preConfigure or ""))
        ;
    in lib.addMetaAttrs ({
        description = "${fpc.meta.description or "fpc"} (fixed for macOS/Darwin, with Clang version capped at 17 to fix build)";
    }) (if needsFix then fpc.overrideAttrs (old: {
        preConfigure = ''
            NIX_LDFLAGS="-syslibroot $SDKROOT -L${lib.getLib pkgs.libiconv}/lib"
        '' + (old.preConfigure or "");
    }) else fpc);
    
    drl-packages = callPackage ./pkgs/drl/packages.nix {};
    inherit (self.drl-packages) drl drl-hq drl-lq;
    
    man2html = callPackage ./pkgs/man2html {};
    
    # qemu-screamer-nixpkgs = callPackage ./pkgs/qemu-screamer/nixpkgs.nix {};
    qemu-screamer = let
        darwinSdkVersion = "11.0";
        stdenv = if pkgs.hostPlatform.isDarwin && pkgs.lib.versionOlder pkgs.stdenv.hostPlatform.darwinSdkVersion darwinSdkVersion then
            pkgs.overrideSDK pkgs.stdenv {
                inherit darwinSdkVersion;
            }
        else
            pkgs.stdenv
        ;
    in callPackage ./pkgs/qemu-screamer {
        inherit stdenv;
        inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices Cocoa Hypervisor vmnet;
        inherit (pkgs.darwin.stubs) rez setfile;
        inherit (pkgs.darwin) sigtool;
    };
    
    wine64Full = let
        inherit (pkgs) lib;
        wine64FullOrig = pkgs.wine64Packages.full;
        needsOldClang = wine64FullOrig.stdenv.cc.isClang && lib.versionAtLeast wine64FullOrig.stdenv.cc.version "17";
        wine64Full = if needsOldClang then (pkgs.wine64Packages.extend (self: super: {
            inherit (pkgs.llvmPackages_16) stdenv;
        })).full else wine64FullOrig;
    in wine64Full.overrideAttrs (old: {
        meta = (old.meta or {}) // {
            description = "${wine64Full.meta.description or "wine64Packages.full"} (with Clang version capped at 16 to fix build)";
        };
        passthru = (old.passthru or {}) // {
            _Rhys-T.allowCI = pkgs.hostPlatform.isDarwin;
        };
    });
    
    _ciOnly.mac = pkgs.lib.optionalAttrs pkgs.hostPlatform.isDarwin (pkgs.lib.recurseIntoAttrs {
        wine64Full = pkgs.wine64Packages.full;
    });
    
    tuxemon = callPackage ./pkgs/tuxemon {};
    tuxemon-git = callPackage ./pkgs/tuxemon/git.nix {};
    libShake = callPackage ./pkgs/libShake {};
    
    fetchurlRhys-T = pkgs.lib.mirrorFunctionArgs pkgs.fetchurl (args: (pkgs.fetchurl args).overrideAttrs (old: {
        mirrorsFile = old.mirrorsFile.overrideAttrs (old: self.myLib.mirrors);
    }));
    fetchzipRhys-T = pkgs.fetchzip.override { fetchurl = self.fetchurlRhys-T; };
    
    phosg = callPackage ./pkgs/resource_dasm/phosg.nix {};
    resource_dasm = callPackage ./pkgs/resource_dasm {};
    
    # _ciOnly.dev = pkgs.lib.optionalAttrs (pkgs.hostPlatform.system == "x86_64-darwin") (pkgs.lib.recurseIntoAttrs {
    #     checkpoint = pkgs.lib.recurseIntoAttrs (pkgs.lib.mapAttrs (k: pkgs.checkpointBuildTools.prepareCheckpointBuild) {
    #         inherit (self)
    #             # hbmame
    #         ;
    #     });
    # });
}); in result // {
    lib = result.myLib;
    modules = result.myModules;
    overlays = result.myOverlays;
}
