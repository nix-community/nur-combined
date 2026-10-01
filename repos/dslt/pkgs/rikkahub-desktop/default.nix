{ symlinkJoin, makeWrapper, pkgs, bun2nix, lib, sources, ... }: let
    # nvfetcher tracks the release tag that the binaries ship from; the Nix
    # version drops the leading "v".
    version = lib.removePrefix "v" sources.rikkahub-desktop.version;
    src = sources.rikkahub-desktop.src;

    # pc-server imports pi's sources through ../../pi/..., so the vendored tree
    # has to sit next to pc-server/ in the source checkout; see pi-vendor.nix.
    rikkahub-pi = pkgs.callPackage ./pi-vendor.nix { inherit sources; };

    runtimeDeps = [
        pkgs.unzip
        pkgs.zip
        pkgs.wl-clipboard
        pkgs.xclip
        pkgs.espeak-ng
    ];

    rikkahub-webui = pkgs.callPackage (
        { stdenv, bun2nix, pkgs, lib, ... }:
        stdenv.mkDerivation {
            pname = "rikkahub-webui";
            inherit version src;

            nativeBuildInputs = [
                bun2nix.hook
                pkgs.nodejs
            ];
            
            bunRoot = "web-ui";
            bunInstallFlags = [
                "--ignore-scripts"
                "--linker=hoisted"
            ];
            dontRunLifecycleScripts = true;

            bunDeps = bun2nix.fetchBunDeps {
                bunNix = ./bun-web-ui.nix;
            };

            postBunSetInstallCacheDirPhase = ''
                chmod -R u+w "$BUN_INSTALL_CACHE_DIR"
            '';

            postBunPatchPhase = ''
                substituteInPlace web-ui/bun.lock \
                    --replace "https://registry.npmmirror.com/" "https://registry.npmjs.org/"
            '';

            buildPhase = ''
                cd web-ui
                node ./node_modules/@react-router/dev/bin.js build
                bun run copy.ts
            '';

            installPhase = ''
                cd ..
                mkdir -p $out/lib/rikkahub
                cp -r dist/. $out/lib/rikkahub/
            '';
        }
    ) { bun2nix = bun2nix; };
    
    rikkahub-pcs = pkgs.callPackage (
        { stdenv, bun2nix, pkgs, lib, ...}:
        stdenv.mkDerivation {
            pname = "rikkahub-pcs";
            inherit version src;

            nativeBuildInputs = [
                bun2nix.hook
            ];

            bunRoot = "pc-server";

            bunDeps = bun2nix.fetchBunDeps {
                bunNix = ./bun-pc-server.nix;
            };

            dontStrip = true;

            postBunSetInstallCacheDirPhase = ''
                chmod -R u+w "$BUN_INSTALL_CACHE_DIR"
            '';

            buildPhase = ''
                # pc-server imports ../../pi/...; put the vendored tree where
                # RikkaHub's Dockerfile clones it. Copied, not symlinked: bun
                # bakes the resolved path into the compiled binary, and a store
                # symlink would therefore pin the whole tree to the output.
                cp -a ${rikkahub-pi} pi

                cd pc-server
                bun build --compile --target=bun-linux-x64 server.ts --outfile ../dist/rikkahub-pc
            '';

            installPhase = ''
                cd ..
                mkdir -p $out/lib/rikkahub
                cp -r dist/. $out/lib/rikkahub/
            '';
        }
    ) { bun2nix = bun2nix; };
in symlinkJoin {
    name = "rikkahub-desktop";
    paths = [ rikkahub-webui rikkahub-pcs ];
    nativeBuildInputs = [ makeWrapper ];
    preferLocalBuild = false;

    postBuild = ''
        rm $out/lib/rikkahub/rikkahub-pc
        install -Dm755 ${rikkahub-pcs}/lib/rikkahub/rikkahub-pc $out/lib/rikkahub/rikkahub-pc

        mkdir -p $out/bin
        makeWrapper $out/lib/rikkahub/rikkahub-pc $out/bin/rikkahub-pc \
            --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps} \
            --run 'export RIKKAHUB_PC_DATA_DIR="$HOME/.rikkahub"'
        ln -s $out/bin/rikkahub-pc $out/bin/rikkahub-desktop
    '';

    meta = {
        description = "RikkaHub desktop built from source";
        homepage = "https://github.com/yuh-G/rikkahub-desktop";
        mainProgram = "rikkahub-pc";
        license = {
            shortName = "rikkahub-segmented-dual";
            fullName = "RikkaHub Segmented Dual License";
            url = "https://github.com/yuh-G/rikkahub-desktop/blob/${sources.rikkahub-desktop.version}/LICENSE";
            free = false;
            redistributable = true;
        };
        platforms = pkgs.lib.platforms.linux;
    };
}
