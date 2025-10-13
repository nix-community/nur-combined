{
    mame, lib, fetchFromGitHub, fetchpatch, icoutils, makeDesktopItem, stdenv,
    writeShellScript,
    common-updater-scripts,
    coreutils,
    curl,
    jq,
    nix-prefetch-git,
}: let
    hbmame' = (mame.override {
        papirus-icon-theme = "DUMMY";
    }).overrideAttrs (old: rec {
        pname = "hbmame";
        version = "0.245.27";
        src = fetchFromGitHub {
            owner = "Robbbert";
            repo = "hbmame";
            tag = "tag${builtins.replaceStrings [ "." ] [ "" ] (lib.removePrefix "0." version)}";
            hash = "sha256-XcPtK5pyKiEzNzzGQe8Rjm19ipW7dlWYh6VWFRL3PWw=";
            forceFetchGit = true; # Avoids unstable hash issues - see:
            # https://github.com/NixOS/nixpkgs/issues/84312
            # https://github.com/NixOS/nixpkgs/issues/259488
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
        outputs = lib.lists.remove "tools" (old.outputs or ["out"]);
        patches = lib.pipe old.patches [
            (builtins.filter (patch: !(lib.hasSuffix "13890.patch" (""+patch))))
            (map (patch: if lib.hasInfix "001-use-absolute-paths" (""+patch) then
                ./patches/001-use-absolute-paths.diff
            else patch))
        ];
        postPatch = builtins.replaceStrings [''
            substituteInPlace src/emu/emuopts.cpp \
              --subst-var-by mamePath "$out/opt/mame"
        ''] [''
            for file in src/emu/emuopts.cpp src/osd/modules/lib/osdobj_common.cpp; do
              substituteInPlace "$file" \
                --subst-var-by mamePath "$out/opt/mame"
            done
        ''] old.postPatch;
        makeFlags = map (x: if x == "TOOLS=1" then "TOOLS=0" else x) (old.makeFlags or []) ++ ["TARGET=hbmame"];
        installPhase = let
            installPhaseParts = builtins.match "(.*)install -Dm644 [^ ]* [^ ]*/mame\\.svg(.*)" old.installPhase;
            installPhase' = ''
                ${builtins.elemAt installPhaseParts 0}
                icotool --extract src/osd/winui/res/hbmame.ico
                install -Dm644 hbmame_1_32x32x32.png "$out"/share/icons/hicolor/32x32/apps/hbmame.png
                ${builtins.elemAt installPhaseParts 1}
            '';
            installPhaseParts' = builtins.match "(.*)# mame-tools.*mv \\$tools/bin/[{],mame-[}]split(.*)" installPhase';
            installPhase'' = lib.concatStrings installPhaseParts';
        in builtins.replaceStrings [
            "install -Dm755 mame -t $out/bin"
            "{artwork,bgfx,plugins,language,ctrlr,keymaps,hash}"
            "installManPage docs/man/*.1 docs/man/*.6"
        ] [
            "install -Dm755 hbmame -t $out/bin"
            "{artwork,bgfx,plugins,language,ctrlr,hash}" # no keymaps included with HBMAME
            "installManPage docs/man/*.6" # not installing tools
        ] installPhase'';
        postInstall = (old.postInstall or "") + ''
            mv "$out"/share/man/man6/{,hb}mame.6
        '';
        postFixup = let
            postFixup = builtins.replaceStrings ["moveToOutput share/man/man1 $tools"] [""] (old.postFixup or "");
        in if postFixup == "\n" then null else postFixup;
        env = (old.env or {}) // {
            NIX_CFLAGS_COMPILE = (old.env.NIX_CFLAGS_COMPILE or "") + lib.optionalString stdenv.cc.isClang (
                " -Wno-error=unused-but-set-variable -Wno-error=unused-private-field"
                # https://github.com/llvm/llvm-project/issues/62254
                + lib.optionalString (stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.cc.version "18") " -fno-builtin-strrchr"
                # Work around HBMAME version of https://github.com/mamedev/mame/issues/13453
                + lib.optionalString (lib.versionAtLeast stdenv.cc.version "20") " -Wno-error=nontrivial-memcall"
            );
        };
        passthru = (old.passthru or {}) // {
            tools = throw "HBMAME's copies of the MAME tools are not supported by the HBMAME developer, and have been removed. Please use the upstream `mame.tools` instead.";
            updateScript = writeShellScript "update-hbmame" ''
                PATH=${lib.makeBinPath [
                    common-updater-scripts
                    curl
                    jq
                ]}
                set -euo pipefail
                latestVersion="$(
                    curl ''${GITHUB_TOKEN:+-H "Authorization: bearer $GITHUB_TOKEN"} https://api.github.com/repos/${src.owner}/${src.repo}/tags | \
                    jq -r '
                        [
                            .[].name |
                            match("tag(?<minor>[0-9]{3})(?<patch>[0-9]*)") |
                            .captures |
                            .[] |= {key: .name, value: .string} |
                            from_entries |
                            "0." + .minor + (if .patch == "" then "" else "."+.patch end)
                        ][0]
                    '
                )"
                update-source-version ''${UPDATE_NIX_ATTR_PATH:-hbmame} "$latestVersion"
            '';
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
in hbmame'
