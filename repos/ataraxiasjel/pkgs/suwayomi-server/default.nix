{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  zip,
  makeWrapper,
  gradle_9,
  copyDesktopItems,
  glib,
  libappindicator,
  jdk25,
  suwayomi-webui,
  _experimental-update-script-combinators,
  nix-update-script,
  writeShellScript,
  electron,
  makeDesktopItem,

  asApplication ? false,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "suwayomi-server";
  version = "2.3.2243";

  __structuredAttrs = true;
  src = fetchFromGitHub {
    owner = "Suwayomi";
    repo = "Suwayomi-Server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QKI014c7ktf6OGB1pd7gKzVGiqBGSZjpMecn2Adu3Ik=";
  };

  patches = [
    ./disable-download.patch
  ];

  postPatch = ''
    # Pin the dynamic version vals (upstream computes them via `git rev-list`,
    # which has no .git in the nix sandbox and would yield v2.3.0/r0).
    # Other vals in Constants.kt (e.g. webviewJbrRelease) are left intact.
    sed -i -E \
      -e 's|^val getTachideskVersion = .*|val getTachideskVersion = { "v${finalAttrs.version}" }|' \
      -e 's|^val webUIRevisionTag = .*|val webUIRevisionTag = "r${suwayomi-webui.revision}"|' \
      -e 's|^val getTachideskRevision = .*|val getTachideskRevision = { "r${lib.versions.patch finalAttrs.version}" }|' \
      buildSrc/src/main/kotlin/Constants.kt
    grep -q 'val getTachideskVersion = { "v${finalAttrs.version}" }' buildSrc/src/main/kotlin/Constants.kt
    grep -q 'val webUIRevisionTag = "r${suwayomi-webui.revision}"' buildSrc/src/main/kotlin/Constants.kt
    grep -q 'val getTachideskRevision = { "r${lib.versions.patch finalAttrs.version}" }' buildSrc/src/main/kotlin/Constants.kt

    substituteInPlace server/src/main/kotlin/suwayomi/tachidesk/server/util/WebInterfaceManager.kt \
      --replace-fail "fetchMD5SumFor(flavor, currentVersion)" '"'"$(cat ${suwayomi-webui}/share/suwayomi-server/md5sum)"'"'

    cp -r ${suwayomi-webui}/share/suwayomi-webui webui
    chmod -R u+xw webui
    (cd webui && zip -9 -r ../server/src/main/resources/WebUI.zip .)
    rm -rf webui
  '';

  nativeBuildInputs = [
    zip
    makeWrapper
    gradle_9
  ]
  ++ lib.optional asApplication copyDesktopItems;

  mitmCache = gradle_9.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
  };

  gradleFlags = [
    "-Dorg.gradle.java.home=${jdk25}"
    "-Dorg.gradle.jvmargs=-Xmx2G"
  ];

  gradleBuildTask = "shadowJar";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/suwayomi-server,share/icons/hicolor/128x128/apps}
    cp server/build/Suwayomi-Server-v${finalAttrs.version}.jar $out/share/suwayomi-server

    # Use nixpkgs suwayomi-webui and disable auto download and update
    makeWrapper ${lib.getExe jdk25} $out/bin/tachidesk-server \
      --add-flags "-Dsuwayomi.tachidesk.config.server.webUIFlavor=WebUI" \
      --add-flags "-Dsuwayomi.tachidesk.config.server.webUIChannel=BUNDLED" \
      --add-flags "-Dsuwayomi.tachidesk.config.server.webUIUpdateCheckInterval=0" \
  ''
  + lib.optionalString asApplication ''
    --prefix LD_LIBRARY_PATH : "${
      lib.makeLibraryPath [
        libappindicator
        glib
      ]
    }" \
    --add-flags "-Dsuwayomi.tachidesk.config.server.webUIInterface=electron" \
    --add-flags '-Dsuwayomi.tachidesk.config.server.electronPath="${lib.getExe electron}"' \
  ''
  + lib.optionalString (!asApplication) ''
    --add-flags "-Dsuwayomi.tachidesk.config.server.initialOpenInBrowserEnabled=false" \
    --add-flags "-Dsuwayomi.tachidesk.config.server.systemTrayEnabled=false" \
  ''
  + ''
      --add-flags "-jar $out/share/suwayomi-server/Suwayomi-Server-v${finalAttrs.version}.jar"

    install -m644 server/src/main/resources/icon/faviconlogo-128.png \
      $out/share/icons/hicolor/128x128/apps/suwayomi-server.png

    runHook postInstall
  '';

  desktopItems = lib.optional asApplication (
    makeDesktopItem (
      with finalAttrs;
      {
        name = "suwayomi-server";
        desktopName = "Suwayomi Server";
        comment = "Free and open source manga reader";
        exec = meta.mainProgram;
        terminal = false;
        icon = "suwayomi-server";
        startupWMClass = "suwayomi-server";
        categories = [ "Utility" ];
      }
    )
  );

  passthru = {
    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script { })
      (writeShellScript "update-deps.sh" ''
        $(nix-build -A suwayomi-server.mitmCache.updateScript)
      '')
    ];
  };

  meta = {
    description = "Free and open source manga reader server that runs extensions built for Mihon (Tachiyomi)";
    longDescription = ''
      Suwayomi is an independent Mihon (Tachiyomi) compatible software and is not a Fork of Mihon (Tachiyomi).

      Suwayomi-Server is as multi-platform as you can get.
      Any platform that runs java and/or has a modern browser can run it.
      This includes Windows, Linux, macOS, chrome OS, etc.
    '';
    homepage = "https://github.com/Suwayomi/Suwayomi-Server";
    downloadPage = "https://github.com/Suwayomi/Suwayomi-Server/releases";
    changelog = "https://github.com/Suwayomi/Suwayomi-Server/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;
    inherit (jdk25.meta) platforms;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
    maintainers = with lib.maintainers; [
      nanoyaki
      ratcornu
      ataraxiasjel
    ];
    mainProgram = "tachidesk-server";
  };
})
