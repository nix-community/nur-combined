# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

# Backported fixes from https://github.com/NixOS/nixpkgs/pull/380440
# See <https://github.com/NixOS/nixpkgs/issues/380436>
let pkgs' = pkgs; in
let pkgs = if with pkgs'; stdenv.hostPlatform.isDarwin && (tests.stdenv.hooks or {})?no-broken-symlinks && !(lib.hasInfix "chmod" (timidity.postInstall or "")) then
    pkgs'.extend (self: super: {
        timidity = super.timidity.overrideAttrs (old: {
            instruments = old.instruments.overrideAttrs (old: {
                urls = ["https://courses.cs.umbc.edu/pub/midia/instruments.tar.gz"];
            });
            postInstall = (old.postInstall or "") + ''
                # All but one of the symlinks in the instruments tarball have their permissions set to 0000.
                # This causes problems on systems like Darwin that actually use symlink permissions.
                chmod -Rh u+rwX $out/share/timidity/
            '';
            dontRewriteSymlinks = null;
        });
    })
else pkgs'; in

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
    
    mame = dontUpdate (callPackage (pkgs.callPackage ./pkgs/mame {}) {});
    mame-metal = dontUpdate (self.mame.override { darwinMinVersion = "11.0"; });
    hbmame = callPackage ./pkgs/mame/hbmame.nix {};
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
        inherit (pkgs) lib fetchFromGitea;
        inherit (self) picolisp;
        picolisp' = picolisp.overrideAttrs (old: {
            version = "25.4.9";
            src = fetchFromGitea {
                domain = "git.envs.net";
                owner = "mpech";
                repo = "pil21";
                rev = "3b4d7927b877a7ecd85969c7f1683079b0dc3d52";
                hash = "sha256-u/5XI5EQW+NME15ry+n0mojC9vXZ6t4c/YR/roCRWpY=";
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
                    jqOrDump() {
                        local data
                        IFS= read -d ''' data
                        set +e
                        printf '%s' "$data" | jq "$@"
                        local exitStatus="$?"
                        if [[ "$exitStatus" -ne 0 ]]; then
                            echo 'Output from server:' >&2
                            echo -E "$branchInfo" >&2
                        fi
                        set -e
                        return "$exitStatus"
                    }
                    eval "$(curl "https://git.envs.net/api/v1/repos/mpech/pil21/branches/master" | jqOrDump -r '
                        (.commit.id) as $latestRev |
                        (.commit.timestamp | scan("^[^T]+")) as $latestDate |
                        @sh "
                            latestRev=\($latestRev)
                            latestDate=\($latestDate)
                        "
                    ')"
                    echo "latestRev=$latestRev" >&2
                    echo "latestDate=$latestDate" >&2
                    eval "$(curl "https://git.envs.net/api/v1/repos/mpech/pil21/contents/src/vers.l?ref=$latestRev" | jqOrDump -r '
                        (.last_commit_sha) as $versRev |
                        (.content | @base64d | scan("\\(pico~de \\*Version (\\d+) (\\d+) (\\d+)\\)") | join(".")) as $versVer |
                        @sh "
                            versRev=\($versRev)
                            versVer=\($versVer)
                        "
                    ')"
                    echo "versRev=$versRev" >&2
                    echo "versVer=$versVer" >&2
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
    
    icbm3d = dontUpdate (pkgs.icbm3d.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
            substituteInPlace makefile --replace-fail 'CC=' '#CC='
            substituteInPlace randnum.c --replace-fail 'stdio.h' 'stdlib.h'
            sed -i '1i\
            #include <string.h>' text.c
        '';
        meta = old.meta // {
            description = "${old.meta.description or "icbm3d"} (fixed for macOS/Darwin)";
            platforms = old.meta.platforms ++ pkgs.lib.platforms.darwin;
            position = myPos "icbm3d";
        };
    }));
    
    xgalagapp = dontUpdate (pkgs.xgalagapp.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
            substituteInPlace Makefile --replace-fail 'CXX =' '#CXX ='
        '';
        meta = old.meta // {
            description = "${old.meta.description or "xgalagapp"} (fixed for macOS/Darwin)";
            platforms = old.meta.platforms ++ pkgs.lib.platforms.darwin;
            position = myPos "xgalagapp";
        };
    }));
    
    fpc = let
        inherit (pkgs) lib;
        fpcOrig = pkgs.fpc;
        needsOldClang = fpcOrig.stdenv.cc.isClang && lib.versionAtLeast fpcOrig.stdenv.cc.version "18";
        fpc = if needsOldClang then fpcOrig.override {
            inherit (pkgs.llvmPackages_17) stdenv;
        } else fpcOrig;
        needsFix =
            pkgs.stdenv.hostPlatform.isDarwin && 
            !(lib.hasInfix "-syslibroot $SDKROOT" (fpc.preConfigure or ""))
        ;
    in dontUpdate (myLib.addMetaAttrsDeep ({
        description = "${fpc.meta.description or "fpc"} (fixed for macOS/Darwin, with Clang version capped at 17 to fix build)";
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
    qemu-screamer = let
        darwinSdkVersion = "11.0";
        stdenv = if pkgs.stdenv.hostPlatform.isDarwin && pkgs.lib.versionOlder pkgs.stdenv.hostPlatform.darwinSdkVersion darwinSdkVersion then
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
    in dontUpdate (wine64Full.overrideAttrs (old: {
        meta = (old.meta or {}) // {
            description = "${wine64Full.meta.description or "wine64Packages.full"} (with Clang version capped at 16 to fix build)";
            position = myPos "wine64Full";
        };
        passthru = (old.passthru or {}) // {
            _Rhys-T.allowCI = pkgs.stdenv.hostPlatform.isDarwin;
        };
    }));
    
    _ciOnly.mac = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin (pkgs.lib.recurseIntoAttrs {
        wine64Full = pkgs.wine64Packages.full;
    });
    
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
    
    phosg = callPackage ./pkgs/resource_dasm/phosg.nix {};
    resource_dasm = callPackage ./pkgs/resource_dasm {};
    
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
