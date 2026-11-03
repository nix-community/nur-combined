# proprietary, no source available; only distributed via google play
{
  requireFile,
  stdenvNoCC,
  apkeditor,
  apktool,
  strip-nondeterminism,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ai-capture";
  version = "1.4";

  src = requireFile {
    name = "AI+Capture_${finalAttrs.version}_APKPure.xapk";
    url = "https://apkpure.com/ai-capture/com.pap.aicapture";
    hash = "sha256-jjQoQKHoW6JznX5+dFy5WYNszleazHoHq83gO9fZDI0=";
  };

  nativeBuildInputs = [
    apkeditor
    apktool
    strip-nondeterminism
    unzip
  ];

  unpackPhase = ''
    runHook preUnpack
    mkdir xapk
    unzip -q $src -d xapk
    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    APKEditor m -i xapk -o merged.apk
    apktool d -s -o decoded merged.apk

    # targetSdk 36 forces edge-to-edge, which makes the action bar cover the top of the content
    substituteInPlace decoded/apktool.yml \
      --replace-fail "targetSdkVersion: 36" "targetSdkVersion: 35"
    sed -i -E 's|(<style name="AppTheme(\.Capture)?" parent="[^"]*">)|\1<item name="android:windowOptOutEdgeToEdgeEnforcement">true</item>|' \
      decoded/res/values/styles.xml
    [[ $(grep -c windowOptOutEdgeToEdgeEnforcement decoded/res/values/styles.xml) == 2 ]]

    apktool b -o unsigned.apk decoded
    strip-nondeterminism --type zip unsigned.apk
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 unsigned.apk $out/apk/release/ai-capture-${finalAttrs.version}-unsigned.apk
    runHook postInstall
  '';

  passthru.applicationIds = [ "com.pap.aicapture" ];
})
