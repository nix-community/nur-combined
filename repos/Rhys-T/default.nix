# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

# Backported updates from <https://github.com/NixOS/nixpkgs/pull/404228>
# See <https://github.com/NixOS/nixpkgs/issues/402811>
let pkgs' = pkgs; in
let
overlays = pkgs'.lib.optional (with pkgs'; (
    lib.getName SDL2 == "sdl2-compat" &&
    lib.getVersion sdl2-compat == "2.32.54"
)) (self: super: {
    sdl3 = super.sdl3.overrideAttrs (old: rec {
        version = "3.2.12";
        src = old.src.override {
            tag = "release-${version}";
            hash = "sha256-CPCbbVbi0gwSUkaEBOQPJwCU2NN9Lex2Z4hqBfIjn+o=";
        };
    });
    sdl2-compat = super.sdl2-compat.overrideAttrs (old: rec {
        version = "2.32.56";
        src = old.src.override {
            tag = "release-${version}";
            hash = "sha256-Xg886KX54vwGANIhTAFslzPw/sZs2SvpXzXUXcOKgMs=";
        };
    });
}) ++ pkgs'.lib.optional (builtins.elem null pkgs'.SDL_compat.buildInputs) (self: super: {
    SDL_compat = super.SDL_compat.overrideAttrs (old: {
        buildInputs = builtins.filter (p: p != null) old.buildInputs;
    });
});
pkgs = if builtins.length overlays > 0 then pkgs'.appendOverlays overlays else pkgs'; in

let result = pkgs.lib.makeScope pkgs.newScope (self: let
    inherit (self) callPackage myLib;
    dontUpdate = p: let
        p' = if p?overrideAttrs then p.overrideAttrs (old: pkgs.lib.optionalAttrs (old?passthru) {
            passthru = removeAttrs old.passthru ["updateScript"];
        }) else p;
    in removeAttrs p' ["updateScript"];
    myPos = name: with builtins.unsafeGetAttrPos "description" self.${name}.meta; "${file}:${toString line}";
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
            pkgs.stdenv.hostPlatform.isDarwin &&
            pkgs.lib.versionOlder pkgs.stdenv.hostPlatform.darwinMinVersion "11.0" &&
            pkgs.lib.versionAtLeast pkgs.allegro5.version "5.2.10.0" &&
            pkgs.lib.versionOlder pkgs.allegro5.version "5.2.10.1"
        ;
    in dontUpdate (pkgs.allegro5.overrideAttrs (old: {
        patches = (old.patches or []) ++ pkgs.lib.optionals needsMacPatch [
            (pkgs.fetchpatch {
                url = "https://github.com/Rhys-T/allegro5/commit/7c928e34042fd7b83d55649f240a38e937ed169b.patch";
                hash = "sha256-mLxEH3m/mFpu7tXkk8snRyLu4fQcJlcq81c/+Zi3pmM=";
            })
        ];
        meta = old.meta // {
            description = (old.meta.description or "allegro5") + " (fixed for macOS/Darwin x86_64 < 11.0)";
            position = myPos "allegro5";
        };
    } // pkgs.lib.optionalAttrs (
        pkgs.stdenv.hostPlatform.isDarwin &&
        !(old?outputs)
    ) {
        outputs = ["out" "dev"];
    }));
    
    lix-game-packages = callPackage ./pkgs/lix-game/packages.nix {};
    lix-game = self.lix-game-packages.game;
    lix-game-server = self.lix-game-packages.server;
    lix-game-libpng = if pkgs.stdenv.hostPlatform.isDarwin then (self.lix-game-packages.overrideScope (self: super: {
        convertImagesToTrueColor = false;
    })).game else self.lix-game;
    lix-game-issue-431 = if pkgs.stdenv.hostPlatform.isDarwin then (self.lix-game-packages.overrideScope (self: super: {
        convertImagesToTrueColor = false;
        disableNativeImageLoader = false;
    })).game else self.lix-game;
    lix-game-CIImage = if pkgs.stdenv.hostPlatform.isDarwin then (self.lix-game-packages.overrideScope (self: super: {
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
    
    # Temporarily work around ldc-developers/ldc#4899 by backporting ldc-developers/ldc#4877
    # and downgrading the bootstrap compiler.
    ldc = let
        inherit (pkgs.stdenv) hostPlatform;
        needsMacPatch =
            hostPlatform.isDarwin &&
            pkgs.lib.versionOlder pkgs.ldc.version "1.40.2" &&
            !(pkgs.lib.any (p: (p.outputHash or null) == "sha256-Y/5+zt5ou9rzU7rLJq2OqUxMDvC7aSFS6AsPeDxNATQ=") pkgs.ldc.patches)
        ;
        ldcBootstrap = pkgs.callPackage (pkgs.path + "/pkgs/by-name/ld/ldc/bootstrap.nix") {};
        OS = if hostPlatform.isDarwin then "osx" else hostPlatform.parsed.kernel.name;
        ARCH = if hostPlatform.isDarwin && hostPlatform.isAarch64 then "arm64" else hostPlatform.parsed.cpu.name;
        oldBootstrapHashes = {
            osx-x86_64 = "sha256-mqQ+hNlDePOGX2mwgEEzHGiOAx3SxfNA6x8+ML3qYmw=";
            osx-arm64 = "sha256-m93rGywncBnPEWslcrXuGBnZ+Z/mNgLIaevkL/uBOu0=";
        };
        oldBootstrap = ldcBootstrap.overrideAttrs (old: rec {
            version = "1.28.1";
            src = pkgs.fetchurl rec {
                name = "ldc2-${version}-${OS}-${ARCH}.tar.xz";
                url = "https://github.com/ldc-developers/ldc/releases/download/v${version}/${name}";
                hash = oldBootstrapHashes."${OS}-${ARCH}" or (throw "missing bootstrap hash for ${OS}-${ARCH}");
            };
        });
    in dontUpdate ((pkgs.ldc.override (pkgs.lib.optionalAttrs needsMacPatch {
        ldcBootstrap = oldBootstrap;
    })).overrideAttrs (old: pkgs.lib.optionalAttrs needsMacPatch {
        patches = (old.patches or []) ++ [(pkgs.fetchpatch {
            url = "https://github.com/ldc-developers/ldc/commit/60079c3b596053b1a70f9f2e0cf38a287089df56.patch";
            hash = "sha256-Y/5+zt5ou9rzU7rLJq2OqUxMDvC7aSFS6AsPeDxNATQ=";
        })];
    } // {
        meta = old.meta // {
            description = (old.meta.description or "ldc") + " (fixed for macOS 15.4)";
            pos = myPos "ldc";
        };
    }));
    dub = dontUpdate ((pkgs.dub.override {
        inherit (self) ldc;
    }).overrideAttrs (old: {
        meta = old.meta // {
            description = (old.meta.description or "dub") + " (fixed for macOS 15.4)";
            pos = myPos "dub";
        };
    }));
    buildDubPackage = pkgs.buildDubPackage.override {
        inherit (self) ldc dub;
    };
    
    xscorch = callPackage ./pkgs/xscorch {};
    
    impluse = callPackage ./pkgs/impluse {};
    
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
    minivmac-ce = callPackage ./pkgs/minivmac/ce.nix {};
    minivmac = self.minivmac36;
    minivmac-unstable = self.minivmac37;
    
    minivmac-ii = self.minivmac.override { macModel = "II"; };
    minivmac-ii-unstable = self.minivmac-unstable.override { macModel = "II"; };
    minivmac-ii-ce = self.minivmac-ce.override { macModel = "II"; };
    
    dc2dsk = callPackage ./pkgs/dc2dsk {};
    
    mame = dontUpdate (callPackage (pkgs.callPackage ./pkgs/mame {}) {});
    mame-metal = dontUpdate (self.mame.override { darwinMinVersion = "11.0"; });
    hbmame = callPackage ./pkgs/mame/hbmame {};
    hbmame-metal = self.hbmame.override { mame = self.mame-metal; };
    
    pacifi3d = callPackage ./pkgs/pacifi3d {};
    pacifi3d-mame = self.pacifi3d.override { romsFromMAME = self.mame; };
    pacifi3d-hbmame = self.pacifi3d.override { romsFromMAME = self.hbmame; };
    _ciOnly.pacifi3d-rom-xmls = pkgs.lib.recurseIntoAttrs {
        mame = self.pacifi3d-mame.romsFromXML;
        hbmame = self.pacifi3d-hbmame.romsFromXML;
    };
    
    # Backported fixes from https://github.com/NixOS/nixpkgs/pull/385459
    picolisp = let
        inherit (pkgs) lib picolisp darwin;
        inherit (pkgs.stdenv) hostPlatform;
        needsLibutil = hostPlatform.isDarwin && !(lib.lists.any (p: (p.pname or null) == "libutil") (pkgs.apple-sdk.propagatedBuildInputs or []));
        picolisp' = if lib.hasInfix "cd src" (picolisp.preBuild or "") then picolisp else picolisp.overrideAttrs (old: {
            preBuild = (old.preBuild or "") + ''
                cd src
            '' + lib.optionalString hostPlatform.isDarwin ''
                # Flags taken from instructions at: https://picolisp.com/wiki/?alternativeMacOSRepository
                makeFlagsArray+=(
                    SHARED='-dynamiclib -undefined dynamic_lookup'
                )
            '';
            buildPhase = null;
            installPhase = builtins.replaceStrings ["--replace "] ["--replace-fail "] old.installPhase;
        } // lib.optionalAttrs needsLibutil {
            buildInputs = (old.buildInputs or []) ++ [darwin.libutil];
        });
    in dontUpdate (myLib.addMetaAttrsDeep ({
        description = (picolisp.meta.description or "PicoLisp") + " (fixed for macOS/Darwin)";
        position = myPos "picolisp";
    }) picolisp');
    
    picolisp-rolling = let
        inherit (pkgs) lib fetchFromGitHub;
        inherit (self) picolisp;
        picolisp' = picolisp.overrideAttrs (old: {
            version = "25.10.12";
            src = fetchFromGitHub {
                owner = "picolisp";
                repo = "pil21";
                rev = "7c6e69d34360f3312f4deb88082c309df596e477";
                hash = "sha256-kwnuKyhed30OBRPe07c+G8sBi4QhXgdxDY3cyWuK4tk=";
            };
            sourceRoot = null;
            passthru = (old.passthru or {}) // {
                updateScript = pkgs.writeShellScript "update-picolisp-rolling" ''
                    PATH=${lib.makeBinPath (with pkgs; [
                        common-updater-scripts
                        coreutils
                        curl
                        gnused
                        jq
                        nix-prefetch-git
                    ])}
                    set -euo pipefail
                    ghcurl() {
                        curl -H 'X-GitHub-Api-Version: 2022-11-28' ''${GITHUB_TOKEN:+ -H "Authorization: bearer $GITHUB_TOKEN"} "$@"
                    }
                    jqOrDump() {
                        local data
                        IFS= read -d ''' data
                        set +e
                        printf '%s' "$data" | jq "$@"
                        local exitStatus="$?"
                        if [[ "$exitStatus" -ne 0 ]]; then
                            echo 'Output from server:' >&2
                            echo -E "$data" >&2
                        fi
                        set -e
                        return "$exitStatus"
                    }
                    eval "$(ghcurl "https://api.github.com/repos/picolisp/pil21/branches/master" | jqOrDump -r '
                        (.commit.sha) as $latestRev |
                        (.commit.commit.author.date | scan("^[^T]+")) as $latestDate |
                        @sh "
                            latestRev=\($latestRev)
                            latestDate=\($latestDate)
                        "
                    ')"
                    echo "latestRev=$latestRev" >&2
                    echo "latestDate=$latestDate" >&2
                    eval "$(ghcurl "https://api.github.com/repos/picolisp/pil21/commits?path=src/vers.l&per_page=1" | jqOrDump -r '
                        (.[0].sha) as $versRev |
                        @sh "
                            versRev=\($versRev)
                        "
                    ')"
                    echo "versRev=$versRev" >&2
                    eval "$(ghcurl "https://raw.githubusercontent.com/picolisp/pil21/$latestRev/src/vers.l" | jqOrDump -Rsr '
                        (scan("\\(pico~de \\*Version (\\d+) (\\d+) (\\d+)\\)") | join(".")) as $versVer |
                        @sh "
                            versVer=\($versVer)
                        "
                    ')"
                    latestVer="$versVer"
                    if [[ "$latestRev" != "$versRev" ]]; then
                        latestVer+="-unstable-$latestDate"
                    fi
                    echo "latestVer=$latestVer" >&2
                    update-source-version ''${UPDATE_NIX_ATTR_PATH:-picolisp-rolling} "$latestVer" --rev="$latestRev"
                '';
            };
        });
    in myLib.addMetaAttrsDeep ({
        description = lib.replaceStrings [") ("] ["; "] ((picolisp.meta.description or "PicoLisp") + " (rolling release)");
        position = myPos "picolisp-rolling";
    }) picolisp';
    
    konify = callPackage ./pkgs/konify {};
    
    asciiportal = callPackage ./pkgs/asciiportal {};
    asciiportal-git = callPackage ./pkgs/asciiportal/git.nix {};
    
    xorcurses = callPackage ./pkgs/xorcurses {};
    xorcurses-git = callPackage ./pkgs/xorcurses/git.nix {};
    
    powder = callPackage ./pkgs/powder {};
    
    xinvaders3d = callPackage ./pkgs/xinvaders3d {};
    
    # Backported updates from <https://github.com/NixOS/nixpkgs/pull/419640>
    icbm3d = let
        inherit (pkgs) stdenv lib icbm3d;
        needsFix = !(lib.any (lib.hasSuffix "-darwin") (icbm3d.meta.platforms or ["-darwin"]));
    in dontUpdate (myLib.addMetaAttrsDeep {
        description = "${icbm3d.meta.description or "icbm3d"} (fixed for macOS/Darwin)";
        platforms = icbm3d.meta.platforms ++ lib.platforms.darwin;
        position = myPos "icbm3d";
    } (if needsFix then icbm3d.overrideAttrs (old: {
        buildFlags = (old.buildFlags or []) ++ [ "CC=${stdenv.cc.targetPrefix}cc" ]; # fix darwin and cross-compiled builds
        postPatch = (old.postPatch or "") + ''
            substituteInPlace randnum.c --replace-fail 'stdio.h' 'stdlib.h'
            sed -i '1i\
            #include <string.h>' text.c
            
            # The Makefile tries to install icbm3d immediately after building it, and
            # ends up trying to copy it to /icbm3d. Normally this just gets an error
            # and moves on, but it's probably better to not try it in the first place.
            sed -i '/INSTALLROOT/d' makefile
        '';
    }) else icbm3d));
    
    xgalagapp = let
        inherit (pkgs) stdenv lib xgalagapp;
        needsFix = !(lib.any (lib.hasSuffix "-darwin") (xgalagapp.meta.platforms or ["-darwin"]));
    in dontUpdate (myLib.addMetaAttrsDeep {
        description = "${xgalagapp.meta.description or "xgalagapp"} (fixed for macOS/Darwin)";
        platforms = xgalagapp.meta.platforms ++ lib.platforms.darwin;
        position = myPos "xgalagapp";
    } (if needsFix then xgalagapp.overrideAttrs (old: {
        buildFlags = [
            "all"
            "HIGH_SCORES_FILE=.xgalaga++.scores"
            "CXX=${stdenv.cc.targetPrefix}c++" # fix darwin and cross-compiled builds
        ];
        buildPhase = null;
        installPhase = ''
            runHook preInstall
            
            ${old.installPhase}
            
            runHook postInstall
        '';
    }) else xgalagapp));
    
    fpc = let
        inherit (pkgs) lib;
        fpcOrig = pkgs.fpc;
        needsOldClang = fpcOrig.stdenv.hostPlatform.isx86_64 && fpcOrig.stdenv.cc.isClang && lib.versionAtLeast fpcOrig.stdenv.cc.version "18" && pkgs?llvmPackages_17 && (builtins.tryEval pkgs.llvmPackages_17).success;
        fpc = if needsOldClang then fpcOrig.override {
            inherit (pkgs.llvmPackages_17) stdenv;
        } else fpcOrig;
        needsFix =
            pkgs.stdenv.hostPlatform.isDarwin && 
            !(lib.hasInfix "-syslibroot $SDKROOT" (fpc.preConfigure or ""))
        ;
    in dontUpdate (myLib.addMetaAttrsDeep ({
        description = "${fpc.meta.description or "fpc"} (fixed for macOS/Darwin, with Clang version capped at 17 to fix build; dead since LLVM 17 removed from Nixpkgs)";
        position = myPos "fpc";
    }) (if needsFix then fpc.overrideAttrs (old: {
        preConfigure = ''
            NIX_LDFLAGS="-syslibroot $SDKROOT -L${lib.getLib pkgs.libiconv}/lib"
        '' + (old.preConfigure or "");
    }) else fpc));
    
    drl-packages = callPackage ./pkgs/drl/packages.nix {};
    inherit (self.drl-packages) drl drl-hq drl-lq;
    
    man2html = callPackage ./pkgs/man2html {};
    
    # qemu-screamer-nixpkgs = callPackage ./pkgs/qemu-screamer/nixpkgs.nix {};
    qemu-screamer = callPackage ./pkgs/qemu-screamer {
        inherit (pkgs.darwin) sigtool;
    };
    
    # _ciOnly.mac = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin (pkgs.lib.recurseIntoAttrs {
    #     wine64Full = pkgs.wine64Packages.full;
    # });
    
    tuxemon = callPackage ./pkgs/tuxemon {};
    tuxemon-git = callPackage ./pkgs/tuxemon/git.nix {};
    libShake = callPackage ./pkgs/libShake {};
    
    xpenguins = callPackage ./pkgs/xpenguins { themes = []; };
    xpenguins-ratrabbit = callPackage ./pkgs/xpenguins/ratrabbit { themes = []; };
    xpenguins-themes-unfree = callPackage ./pkgs/xpenguins/themes-unfree.nix {};
    
    fetchFromGitHub = if (pkgs.lib.functionArgs pkgs.fetchFromGitHub)?tag then pkgs.fetchFromGitHub else let
        fetchFunc = {tag?null, ...}@args: pkgs.fetchFromGitHub (removeAttrs args ["tag"] // pkgs.lib.optionalAttrs (tag != null) {rev = "refs/tags/${tag}";});
        fetchArgs = pkgs.lib.functionArgs pkgs.fetchFromGitHub // pkgs.functionArgs fetchFunc;
        final = pkgs.lib.setFunctionArgs fetchFunc fetchArgs;
    in final;
    fetchurlRhys-T = pkgs.lib.mirrorFunctionArgs pkgs.fetchurl (args: (pkgs.fetchurl args).overrideAttrs (old: {
        mirrorsFile = old.mirrorsFile.overrideAttrs (old: self.myLib.mirrors);
    }));
    fetchzipRhys-T = pkgs.fetchzip.override { fetchurl = self.fetchurlRhys-T; };
    
    fuzziqersoftwareFmtPatchHook = callPackage ./pkgs/resource_dasm/fmt-patch-hook {};
    phosg = callPackage ./pkgs/resource_dasm/phosg.nix {};
    resource_dasm = callPackage ./pkgs/resource_dasm {};
    
    shapez-ce = callPackage ./pkgs/shapez-ce {};
    _ciOnly.shapez-ce-src = self.shapez-ce.src;
        
    # _ciOnly.dev = pkgs.lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-darwin") (pkgs.lib.recurseIntoAttrs {
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
