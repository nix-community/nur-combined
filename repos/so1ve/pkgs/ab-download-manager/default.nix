{
  alsa-lib,
  autoPatchelfHook,
  fetchurl,
  fontconfig,
  freetype,
  lib,
  libGL,
  libX11,
  libXext,
  libXi,
  libXrender,
  libXtst,
  libxkbcommon,
  makeWrapper,
  stdenv,
  uiScale ? null,
  wayland,
  zlib,
}:

assert lib.assertMsg (
  uiScale == null || ((builtins.isInt uiScale || builtins.isFloat uiScale) && uiScale > 0)
) "ab-download-manager: uiScale must be null or a positive number";

let
  release = builtins.fromJSON (builtins.readFile ./sources.json);
  source =
    release.sources.${stdenv.hostPlatform.system}
      or (throw "ab-download-manager: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ab-download-manager";
  inherit (release) version;

  src = fetchurl {
    url = "https://github.com/amir1376/ab-download-manager/releases/download/v${finalAttrs.version}/ABDownloadManager_${finalAttrs.version}_linux_${source.arch}.tar.gz";
    inherit (source) hash;
  };

  sourceRoot = "ABDownloadManager";

  strictDeps = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
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
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ fontconfig ]}"
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
    Exec=ABDownloadManager %U
    Icon=com.abdownloadmanager
    Categories=Network;FileTransfer;
    Terminal=false
    StartupNotify=true
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
    upstreamSources = release.sources;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Download manager with browser integration";
    homepage = "https://abdownloadmanager.com";
    changelog = "https://github.com/amir1376/ab-download-manager/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "ABDownloadManager";
    platforms = builtins.attrNames release.sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
