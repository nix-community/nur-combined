{
  alsa-lib,
  autoPatchelfHook,
  callPackage,
  fontconfig,
  freetype,
  jdk25_headless,
  lib,
  libGL,
  libX11,
  libXext,
  libXi,
  libXrender,
  libXtst,
  libxkbcommon,
  makeWrapper,
  source ?
    (callPackage ../../_sources/generated.nix { })."ab-download-manager-${stdenv.hostPlatform.system}",
  stdenv,
  uiScale ? null,
  wayland,
  zlib,
}:

assert lib.assertMsg (
  uiScale == null || ((builtins.isInt uiScale || builtins.isFloat uiScale) && uiScale > 0)
) "ab-download-manager: uiScale must be null or a positive number";

stdenv.mkDerivation (finalAttrs: {
  pname = "ab-download-manager";
  inherit (source) version src;

  sourceRoot = "ABDownloadManager";

  strictDeps = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    jdk25_headless
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    fontconfig
    freetype
    libGL
    libX11
    libXext
    libXi
    libXrender
    libXtst
    libxkbcommon
    stdenv.cc.cc.lib
    wayland
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/opt/ab-download-manager"
    cp -r bin lib "$out/opt/ab-download-manager/"

    auto_start_jars=("$out/opt/ab-download-manager/lib/app"/auto-start-desktop-*.jar)
    if [[ ''${#auto_start_jars[@]} -ne 1 || ! -f "''${auto_start_jars[0]}" ]]; then
      echo "expected exactly one auto-start-desktop JAR" >&2
      exit 1
    fi

    mkdir -p nix-autostart-classes
    install -m444 ${./Startup.java} Startup.java
    javac \
      --release 25 \
      -cp "''${auto_start_jars[0]}" \
      -d nix-autostart-classes \
      Startup.java
    jar --create \
      --file "$out/opt/ab-download-manager/lib/app/nix-disable-autostart.jar" \
      -C nix-autostart-classes .

    for config_file in "$out/opt/ab-download-manager/lib/app"/*.cfg; do
      substituteInPlace "$config_file" \
        --replace-fail \
        "[Application]" \
        $'[Application]\napp.classpath=$APPDIR/nix-disable-autostart.jar'
    done

    ${lib.optionalString (uiScale != null) ''
      substituteInPlace \
        "$out/opt/ab-download-manager/lib/app/ABDownloadManager.cfg" \
        --replace-fail \
        "[JavaOptions]" \
        $'[JavaOptions]\njava-options=-Dsun.java2d.uiScale=${toString uiScale}'
    ''}

    mkdir -p "$out/bin"
    for program in \
      ABDownloadManager \
      ABDownloadManagerCli \
      ABDownloadManagerNativeMessagingHost
    do
      makeWrapper \
        "$out/opt/ab-download-manager/bin/$program" \
        "$out/bin/$program" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ fontconfig ]}" \
        --set-default FONTCONFIG_FILE "${fontconfig.out}/etc/fonts/fonts.conf"
    done

    install -Dm444 \
      "$out/opt/ab-download-manager/lib/ABDownloadManager.png" \
      "$out/share/pixmaps/com.abdownloadmanager.png"

    install -Dm444 /dev/stdin \
      "$out/share/applications/com.abdownloadmanager.desktop" <<EOF
    [Desktop Entry]
    Type=Application
    Name=AB Download Manager
    Comment=Manage and accelerate downloads
    Exec=ABDownloadManager
    Icon=com.abdownloadmanager
    Categories=Network;FileTransfer;
    Terminal=false
    StartupWMClass=com-abdownloadmanager-desktop-AppKt
    EOF

    install -Dm444 /dev/stdin \
      "$out/lib/mozilla/native-messaging-hosts/com.abdownloadmanager.json" <<EOF
    {
      "name": "com.abdownloadmanager",
      "description": "AB Download Manager",
      "path": "$out/bin/ABDownloadManagerNativeMessagingHost",
      "type": "stdio",
      "allowed_extensions": [
        "firefox-integration@abdownloadmanager.com"
      ]
    }
    EOF

    runHook postInstall
  '';

  passthru = {
    inherit uiScale;
  };

  meta = {
    description = "Download manager with browser integration";
    homepage = "https://abdownloadmanager.com";
    changelog = "https://github.com/amir1376/ab-download-manager/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "ABDownloadManager";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
