{
    maintainers,
    stdenv,
    fetchzip,
    lib,
    makeWrapper,
    xdg-utils,
    electron,
    makeDesktopItem,
    copyDesktopItems,
    ...
}: let
    programName = "jlc-assistant";
    programNameDesc = "JLC Assistant";
    programVersion = "5.0.69";

    desktopEntry = makeDesktopItem {
        name = programName;
        desktopName = programNameDesc;
        exec = "jlc-assistant %u";
        icon = "jlc-assistant";
        categories = [ "Development" ];
        extraConfig = {
            "Name[zh_CN]" = "嘉立创下单助手";
        };
    };
in stdenv.mkDerivation {
    pname = programName;
    version = programVersion;
    src = fetchzip {
        url = "https://download.jlc.com/pcAssit/5.0.69/JLCPcAssit-linux-x64-5.0.69.zip";
        hash = "sha256-LIysqXCXoVV49dGPqK2nYSO6jRG/qFR4RnAnpismfLs=";
        stripRoot = false;
    };

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [ makeWrapper copyDesktopItems ];

    installPhase = let
        dirPrefix = "jlc-assistant-linux-x64-${programVersion}";
    in ''
        runHook preInstall

        mkdir -p $out/bin $TEMPDIR/${programName}
        cp -rf ${dirPrefix}/${programName} $out/${programName}

        makeWrapper ${electron}/bin/electron $out/bin/${programName} \
            --add-flags $out/${programName}/resources/app.asar \
            --add-flags "--gtk4 --enable-wayland-ime" \
            --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ stdenv.cc.cc ]}" \
            --set PATH "${lib.makeBinPath [ xdg-utils ]}"

        mkdir -p $out/share/icons/hicolor/512x512/apps
        install -Dm444 $out/${programName}/icon/png/512.png $out/share/icons/${programName}.png
        install -Dm444 $out/${programName}/icon/png/512.png $out/share/icons/hicolor/512x512/apps/${programName}.png

        mkdir -p $out/share/applications

        runHook postInstall
    '';

    preFixup = ''
        patchelf \
            --set-rpath "$out/${programName}" \
            $out/${programName}/${programName}
    '';

    desktopItems = [ desktopEntry ];

    meta = with lib; {
        homepage = "https://www.jlc.com/portal/appDownloadsWithConfig.html";
        description = "JLCPCB Order Assistant - This app provides you with convenient ordering, allowing you to quickly access discounts and order information without waiting for review on the website! Enjoy instant discounts with the help of our ordering assistant!";
        license = licenses.unfree;
        sourceProvenance = with lib.sourceTypes; [
            binaryNativeCode
            binaryBytecode
            binaryData
        ];
        maintainers = [ maintainers.srcres258 ];
        platforms = platforms.linux;
        mainProgram = programName;
        broken = true;
    };
}

