{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_8,
  jdk21,
  fontconfig,
  libXinerama,
  libXrandr,
  file,
  gtk3,
  glib,
  cups,
  lcms2,
  alsa-lib,
  libglvnd,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bifrost";
  version = "1.20.4";

  src = fetchFromGitHub {
    owner = "zacharee";
    repo = "SamloaderKotlin";
    tag = finalAttrs.version;
    hash = "sha256-fADiOJ1J/3QTWC6+e09apbpJWY+iWdV+olRLQIOtf5Q=";
  };

  postPatch = ''
    echo "kotlin.native.ignoreDisabledTargets=true" >> local.properties
    substituteInPlace desktop/build.gradle.kts \
      --replace-fail "this.vendor.set(JvmVendorSpec.MICROSOFT)" ""
  '';

  gradleBuildTask = ":desktop:createReleaseDistributable";
  gradleUpdateTask = finalAttrs.gradleBuildTask;

  mitmCache = gradle_8.fetchDeps {
    inherit (finalAttrs) pname;
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
    silent = false;
    useBwrap = false;
  };

  env.JAVA_HOME = jdk21;

  gradleFlags = [
    "-Dorg.gradle.java.home=${jdk21}"
  ];

  nativeBuildInputs = [
    gradle_8
    jdk21
    copyDesktopItems
    autoPatchelfHook
  ];

  buildInputs = [
    fontconfig
    libXinerama
    libXrandr
    file
    gtk3
    glib
    cups
    lcms2
    alsa-lib
    libglvnd
  ];

  doCheck = false;

  desktopItems = [
    (makeDesktopItem {
      name = "bifrost";
      exec = "Bifrost";
      icon = "bifrost";
      desktopName = "Bifrost";
      comment = "Samsung firmware downloader";
      categories = [ "Utility" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    cp --recursive desktop/build/compose/binaries/main-release/app/Bifrost $out
    install -D --mode=0644 $out/lib/Bifrost.png \
      $out/share/icons/hicolor/512x512/apps/bifrost.png

    runHook postInstall
  '';

  meta = {
    description = "Samsung firmware downloader";
    homepage = "https://github.com/zacharee/SamloaderKotlin";
    license = lib.licenses.mit;
    mainProgram = "Bifrost";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ onny ];
  };
})
