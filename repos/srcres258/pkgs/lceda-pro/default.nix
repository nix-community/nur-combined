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
    programName = "lceda-pro";
    programNameDesc = "LCEDA Pro";
    programVersion = "3.2.91";

    desktopEntry = makeDesktopItem {
        name = programName;
        desktopName = programNameDesc;
        exec = "lceda-pro %u";
        icon = "lceda";
        categories = [ "Development" ];
        extraConfig = {
            "Name[zh_CN]" = "嘉立创EDA专业版";
        };
    };
in stdenv.mkDerivation {
    pname = programName;
    version = programVersion;
    src = fetchzip {
        url = "https://image.lceda.cn/files/lceda-pro-linux-x64-${programVersion}.zip";
        hash = "sha256-sNyKQcRz5cZ4QlqqIAxgAGuKzsSN7N5BiJTgfSTJvYw=";
        stripRoot = false;
    };

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [ makeWrapper copyDesktopItems ];

    installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $TEMPDIR/${programName}
        cp -rf ${programName} $out/${programName}
        mv $out/${programName}/resources/app/assets/db/lceda-std.elib $TEMPDIR/${programName}/db.elib

        makeWrapper ${electron}/bin/electron $out/bin/${programName} \
            --add-flags $out/${programName}/resources/app/ \
            --add-flags "--gtk4 --enable-wayland-ime" \
            --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ stdenv.cc.cc ]}" \
            --set PATH "${lib.makeBinPath [ xdg-utils ]}"

        mkdir -p $out/share/icons/hicolor/512x512/apps
        install -Dm444 $out/${programName}/icon/icon_512x512.png $out/share/icons/lceda.png
        install -Dm444 $out/${programName}/icon/icon_512x512.png $out/share/icons/hicolor/512x512/apps/lceda.png

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
        homepage = "https://lceda.cn/";
        description = "Highly efficient domestic PCB design tools, permanently free";
        license = licenses.unfree;
        sourceProvenance = with lib.sourceTypes; [
            binaryNativeCode
            binaryBytecode
            binaryData
        ];
        maintainers = [ maintainers.srcres258 ];
        platforms = [ "x86_64-linux" ];
        mainProgram = programName;
    };
}

