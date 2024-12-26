{ mame, lib, fetchFromGitHub, fetchpatch, icoutils, makeDesktopItem, stdenv, doSplitBuildHack ? stdenv.hostPlatform.system == "aarch64-linux", checkpointBuildTools }: let
    hbmame' = (mame.override {
        papirus-icon-theme = "DUMMY";
    }).overrideAttrs (old: rec {
        pname = "hbmame";
        version = "0.245.21";
        src = fetchFromGitHub {
            owner = "Robbbert";
            repo = "hbmame";
            rev = "tag${builtins.replaceStrings [ "." ] [ "" ] (lib.removePrefix "0." version)}";
            sha256 = "sha256-q0m0h5nOuDdVm+VPzJXTU0XZjNKwNE7ugHzvHxZsBo0=";
        };
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [icoutils];
        desktopItems = [
            (makeDesktopItem {
                name = "HBMAME";
                desktopName = "HBMAME";
                exec = "hbmame";
                icon = "hbmame";
                type = "Application";
                genericName = "Multi-purpose homebrew emulation framework";
                # comment = "Play vintage games using the MAME emulator";
                categories = [ "Game" "Emulator" ];
                keywords = [ "Game" "Emulator" "Arcade" ];
            })
        ];
        patches = map (patch: if lib.hasInfix "001-use-absolute-paths" (""+patch) then fetchpatch {
            url = "https://raw.githubusercontent.com/NixOS/nixpkgs/83d89a2fadf3ce1f67cfc5e49e62e474df04507b/pkgs/applications/emulators/mame/001-use-absolute-paths.diff";
            decode = '' sed '/OPTION_INIPATH/ {
                s@".;ini;ini/presets",@"ini",  @g
                s@$@  // MESSUI@g
            }' '';
            hash = "sha256-mOgS03wKLJEnQM91rjZvsFE5mkafdIZnmk3vp0YgNaU=";
        } else patch) old.patches ++ [
            (fetchpatch {
                name = "0001-PATCH-3rdparty-sol2-Fixed-build-with-clang-19.patch";
                url = "https://github.com/mamedev/mame/commit/c75845b1ef01d76379bcc0a6937f1ca678484c68.patch";
                hash = "sha256-uU+GFxEifJkmFi2SzurIRWmnTzokhCPJa7AuTlFOTjQ=";
            })
            (fetchpatch {
                name = "0002-Use-EQUIVALENT_ARRAY-to-avoid-issues-with-std-size.patch";
                url = "https://github.com/mamedev/mame/commit/0ae68e4dea29dd55338bc829b72a67d2f59debf7.patch";
                hash = "sha256-CAkmqI/gcf+W3lCUyMU2MVr1YItzsA3TmwGM4MopxUo=";
            })
        ];
        makeFlags = (old.makeFlags or []) ++ ["TARGET=hbmame"];
        installPhase = let
            installPhaseParts = builtins.match "(.*)install -Dm644 [^ ]* [^ ]*/mame\\.svg(.*)" old.installPhase;
            installPhase' = ''
                ${builtins.elemAt installPhaseParts 0}
                icotool --extract src/osd/winui/res/hbmame.ico
                install -Dm644 hbmame_1_32x32x32.png "$out"/share/icons/hicolor/32x32/apps/hbmame.png
                ${builtins.elemAt installPhaseParts 1}
            '';
        in builtins.replaceStrings [
            "install -Dm755 mame -t $out/bin"
            "{artwork,bgfx,plugins,language,ctrlr,keymaps,hash}"
        ] [
            "install -Dm755 hbmame -t $out/bin"
            "{artwork,bgfx,plugins,language,ctrlr,hash}" # no keymaps included with HBMAME
        ] installPhase';
        postInstall = (old.postInstall or "") + ''
            mv "$out"/share/man/man6/{,hb}mame.6
        '';
        env = (old.env or {}) // {
            NIX_CFLAGS_COMPILE = (old.env.NIX_CFLAGS_COMPILE or "") + lib.optionalString stdenv.cc.isClang (
                " -Wno-error=unused-but-set-variable -Wno-error=unused-private-field" +
                # https://github.com/llvm/llvm-project/issues/62254
                lib.optionalString (stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.cc.version "18") " -fno-builtin-strrchr"
            );
        };
        meta = (old.meta or {}) // {
            description = "Emulator of homebrew and hacked games for arcade hardware";
            longDescription = ''
                HBMAME (HomeBrew MAME) is a derivative of MAME ${builtins.concatStringsSep "." (lib.lists.take 2 (builtins.splitVersion version))}, and contains various hacks and homebrews.
                
                What's in it?
                
                - Homebrew games meant for arcade hardware, or emulators of arcade hardware
                - Hacks of arcade games
                - Test roms and similar that do not generate revenue
                - Selected bootlegs that are not in MAME
                - Games that are enhanced or improved but not suitable for MAME
                - Suitable games that MAME has rejected 
                
                Do NOT report any problems to Mametesters. Any issues can be reported at the 
                [HBMAME forum at MameWorld.info](https://www.mameworld.info/ubbthreads/postlist.php?Cat=&Board=misfitmame).
            '';
            homepage = "https://hbmame.1emulation.com/";
            mainProgram = "hbmame";
        };
    });
in if doSplitBuildHack then let
    phase1 = hbmame'.overrideAttrs (old: {
        pname = old.pname + "-phase1";
        buildFlags = (old.buildFlags or []) ++ ["generate"];
    });
    artifacts = checkpointBuildTools.prepareCheckpointBuild phase1;
    hbmame'' = checkpointBuildTools.mkCheckpointBuild hbmame' artifacts;
in hbmame'' else hbmame'
