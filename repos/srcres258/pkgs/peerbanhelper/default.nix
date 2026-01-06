{
    maintainers,
    fetchurl,
    stdenvNoCC,
    lib,
    jdk21_headless,
    makeWrapper,
    unzip
}: let
    pname = "peerbanhelper";
    version = "9.2.2";
    src = fetchurl {
        url = "https://github.com/Ghost-chu/PeerBanHelper/releases/download/v9.2.2/PeerBanHelper_9.2.2.zip";
        hash = "sha256-bs770tTJayoO3wnij0PWF25k6PZtvwMqQIZ2kouQIYg=";
    };
in stdenvNoCC.mkDerivation (finalAttrs: {
    inherit pname version src;

    nativeBuildInputs = [
        makeWrapper
        unzip
    ];

    installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/opt
        cp PeerBanHelper.jar $out/opt/peerbanhelper.jar
        cp -r libraries $out/opt/libraries

        makeWrapper ${jdk21_headless}/bin/java $out/bin/peerbanhelper \
            --add-flags "-jar" \
            --add-flags "$out/opt/peerbanhelper.jar"

        runHook postInstall
    '';

    meta = {
        changelog = "https://github.com/Ghost-chu/PeerBanHelper/releases/tag/${finalAttrs.version}";
        maintainers = maintainers.srcres258;
        description = "Automatically bans unwanted, leeching, and anomalous BT clients, with support for custom rules for qBittorrent and Transmission";
        homepage = "https://github.com/Ghost-chu/PeerBanHelper";
        license = lib.licenses.gpl3Only;
        mainProgram = "peerbanhelper";
    };
})

