{
  lib,
  bash,
  jdk21,
  stdenv,
  stdenvNoCC,
  tasks,

  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,

  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  fontconfig,
  freetype,
  glib,
  gtk3,
  libGL,
  libx11,
  libxext,
  libxi,
  libxrender,
  libxtst,
  pango,
  zlib,
}:
stdenvNoCC.mkDerivation {
  pname = "tasks-org-desktop";
  inherit (tasks) version;

  dontUnpack = true;

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/opt/tasks-org"
    cp -a ${tasks}/desktop/tasks-org/. "$out/opt/tasks-org/"

    install -Dm755 ${./launcher.bash} "$out/opt/tasks-org/bin/tasks-org"
    substituteInPlace "$out/opt/tasks-org/bin/tasks-org" \
      --replace-fail '@bash@' '${lib.getExe bash}' \
      --replace-fail '@java@' '${lib.getExe jdk21}'

    rm -r "$out/opt/tasks-org/lib/runtime"
    rm "$out/opt/tasks-org/lib/libapplauncher.so"

    install -Dm644 ${tasks}/desktop/icon.svg \
      "$out/share/icons/hicolor/scalable/apps/tasks-org.svg"

    makeWrapper "$out/opt/tasks-org/bin/tasks-org" \
      "$out/bin/tasks-org" \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          alsa-lib
          at-spi2-atk
          cairo
          cups
          fontconfig
          freetype
          glib
          gtk3
          libGL
          libx11
          libxext
          libxi
          libxrender
          libxtst
          pango
          stdenv.cc.cc
          zlib
        ]
      }

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "tasks-org";
      exec = "tasks-org";
      icon = "tasks-org";
      desktopName = "Tasks.org";
      genericName = "Task manager";
      categories = [ "Office" ];
    })
  ];

  meta = {
    description = "Open-source to-do lists and reminders";
    homepage = "https://tasks.org/";
    changelog = "https://github.com/tasks/tasks/blob/${tasks.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
    mainProgram = "tasks-org";
    maintainers = [ lib.maintainers.shelvacu ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
