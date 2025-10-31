{
    stdenv, lib,
    buildNpmPackage, fetchNpmDeps,
    fetchFromGitHub, fetchurl,
    electron_37,
    ffmpeg, jre, zip,
    removeReferencesTo, buildPackages, makeBinaryWrapper,
    copyDesktopItems, makeDesktopItem, iconConvTools,
    maintainers,
}: buildNpmPackage (finalAttrs: let
    electron = electron_37;
in {
    pname = "shapez-ce";
    version = "0-unstable-2025-10-11";
    src = fetchFromGitHub {
        owner = "tobspr-games";
        repo = "shapez-community-edition";
        rev = "9676c8e28cd5a79cbd7adfab52867152446cb9f3";
        hash = "sha256-wq5brNoB8SNzpAWm4FSw0I/IWMpIRWdPtTKP5H168+8=";
    };
    texturePacker = fetchurl {
        url = "https://web.archive.org/web/20241202185338id_/https://libgdx-nightlies.s3.amazonaws.com/libgdx-runnables/runnable-texturepacker.jar";
        hash = "sha256-M0fvcxIzdMrHq87+dd3N99fvGJARYD7EUth/Gli2q80=";
    };
    npmRebuildFlags = [ "--ignore-scripts" ];
    env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    npmDepsHash = "sha256-GVeOatGtyKkeRunKrse4c+00UGJlRJWxvVlplpZ47H0=";
    electronNpmDeps = fetchNpmDeps {
        name = "${finalAttrs.finalPackage.name}-electron-npm-deps";
        inherit (finalAttrs) src;
        sourceRoot = "source/electron";
        hash = "sha256-Z4NU/jpcsJa2HlmCd/kj0QMAAAI7Y/Zs8Jirh6zTqHc=";
    };
    postPatch = ''
        sed -Ei '
            /function getRevision/a\
            return "${finalAttrs.src.rev}";
        ' gulp/buildutils.js
        # Fix build type string so it doesn't show up as 'undefined'
        # Base G_BUILD_TIME on SOURCE_DATE_EPOCH for reproducibility
        substituteInPlace gulp/webpack.production.config.js \
            --replace-fail \
                '"G_APP_ENVIRONMENT": JSON.stringify("release")' \
                '"G_APP_ENVIRONMENT": JSON.stringify("prod")' \
            --replace-fail \
                '"G_BUILD_TIME": new Date().getTime().toString()' \
                '"G_BUILD_TIME": new Date(process.env["SOURCE_DATE_EPOCH"]*1000).getTime().toString()'
    '';
    nativeBuildInputs = [jre ffmpeg zip removeReferencesTo makeBinaryWrapper] ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [copyDesktopItems iconConvTools];
    postConfigure = ''
        cp src/js/core/config.local.template.js src/js/core/config.local.js
        ln -s "$texturePacker" gulp/runnable-texturepacker.jar
        
        # load additional npm deps from electron/package-lock.json:
        configElectronDeps() {
            pushd electron
            local npmDeps="$electronNpmDeps"
            npmConfigHook
            popd
        }
        configElectronDeps
        
        # electron files need to be writable on Darwin
        cp -r ${electron.dist} electron-dist
        chmod -R u+w electron-dist
        
        pushd electron-dist
        zip -0Xqr ../electron.zip .
        popd
        
        rm -r electron-dist
        
        # force @electron/packager to use our electron instead of downloading it, even if it is a different version
        substituteInPlace node_modules/@electron/packager/dist/packager.js \
            --replace-fail 'await this.getElectronZipPath(downloadOpts)' "\"$PWD/electron.zip\""
    '';
    preBuild = ''
        ln -s ${lib.getExe buildPackages.pngquant} node_modules/pngquant-bin/vendor/pngquant
        ln -s ${lib.getExe buildPackages.optipng} node_modules/optipng-bin/vendor/optipng
        ln -s ${lib.getExe' buildPackages.gifsicle "gifsicle"} node_modules/gifsicle/vendor/gifsicle
        npmBuildScript="package-$npm_config_platform-$npm_config_arch"
    '';
    desktopItems = lib.optionals (!stdenv.hostPlatform.isDarwin) [
        (makeDesktopItem {
            name = "shapez-ce";
            exec = "shapez-ce";
            icon = "shapez-ce";
            desktopName = "Shapez Community Edition";
            genericName = "Factory-Building Game";
            comment = "Open source base building game inspired by Factorio (community-maintained fork)";
            categories = [ "Game" ];
        })
    ];
    installPhase = ''
        runHook preInstall
        ${if stdenv.hostPlatform.isDarwin then ''
            mkdir -p "$out/Applications" "$out/bin"
            cp -R build_output/standalone/shapez-*/shapez.app "$out/Applications/shapez.app"
            
            makeBinaryWrapper "$out/Applications/shapez.app/Contents/MacOS/shapezio" "$out/bin/shapez-ce"
        '' else ''
            mkdir -p "$out/share/shapez-ce" "$out/bin"
            cp -R build_output/standalone/shapez-*/{locales,resources{,.pak}} "$out/share/shapez-ce"
            
            install -Dm644 electron/favicon.png "$out/share/icons/hicolor/512x512/apps/shapez-ce.png"
            icoFileToHiColorTheme electron/favicon.ico shapez-ce "$out"
            
            makeBinaryWrapper ${lib.getExe electron} "$out/bin/shapez-ce" \
                --add-flags "$out/share/shapez-ce/resources/app.asar" \
                --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
                --inherit-argv0
        ''}
        mkdir -p "$out/share/licenses/shapez-ce"
        cp LICENSE "$out/share/licenses/shapez-ce/"
        runHook postInstall
    '';
    postFixup = ''
        shopt -s globstar
        remove-references-to -t "$(type -P node)" "$out"/**/*.asar
        shopt -u globstar
    '';
    meta = {
        description = "Open source base building game inspired by Factorio (community-maintained fork)";
        homepage = "https://github.com/tobspr-games/shapez-community-edition";
        license = lib.licenses.gpl3Plus;
        mainProgram = "shapez-ce";
        maintainers = [maintainers.Rhys-T];
        platforms = [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
        ];
    };
})
