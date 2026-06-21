{ symlinkJoin, makeWrapper, pkgs, bun2nix, ... }: let
    runtimeDeps = [
        pkgs.unzip
        pkgs.zip
        pkgs.wl-clipboard
        pkgs.xclip
        pkgs.espeak-ng
    ];

    rikkahub-webui = pkgs.callPackage (
        { stdenv, bun2nix, pkgs, lib, fetchFromGitHub, ... }:
        stdenv.mkDerivation {
            pname = "rikkahub-webui";
            version = "git";

            src = fetchFromGitHub {
                owner = "yuh-G";
                repo = "rikkahub-desktop";
                rev = "645f6f8439321941fed21ba7f53008bbc8b1853c";
                hash = "sha256-oQy0f5Nfh8+0IvsPk9Li3ezTfJabBNBdKK+Q6X2aKyY=";
            };

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
                    --replace-fail "https://registry.npmmirror.com/" "https://registry.npmjs.org/"
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
        { stdenv, bun2nix, pkgs, lib, fetchFromGitHub, ...}:
        stdenv.mkDerivation {
            pname = "rikkahub-pcs";
            version = "git";

            src = fetchFromGitHub {
                owner = "yuh-G";
                repo = "rikkahub-desktop";
                rev = "645f6f8439321941fed21ba7f53008bbc8b1853c";
                hash = "sha256-oQy0f5Nfh8+0IvsPk9Li3ezTfJabBNBdKK+Q6X2aKyY=";
            };

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
        broken = true;
        license = {
            shortName = "rikkahub-segmented-dual";
            fullName = "RikkaHub Segmented Dual License";
            url = "https://github.com/yuh-G/rikkahub-desktop/blob/645f6f8439321941fed21ba7f53008bbc8b1853c/LICENSE";
            free = false;
            redistributable = true;
        };
        platforms = pkgs.lib.platforms.linux;
    };
}
