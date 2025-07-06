{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  jdk,
  ffmpeg,
  python3,
  yt-dlp,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xdman";
  version = "7.2.11";

  src = fetchurl {
    url = "https://github.com/subhra74/xdm/releases/download/${finalAttrs.version}/xdman.jar";
    hash = "sha256-gRfyhvneHlf0VRZ22PCrPi6ZBER0S1lffMTLngH1HHw=";
  };

  nativeBuildInputs = [
    jdk
    makeWrapper
  ];

  buildInputs = [
    ffmpeg
    python3
    yt-dlp
  ];

  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;
  dontPatchELF = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/java/xdman}
    cp $src $out/share/java/xdman/xdman.jar

    path=${lib.makeBinPath [ffmpeg yt-dlp]}

    makeWrapper ${jdk}/bin/java $out/bin/xdman \
      --set JAVA_HOME ${jdk.home} \
      --prefix PATH : "$path" \
      --add-flags "-jar $out/share/java/xdman/xdman.jar"

    runHook postInstall
  '';

  meta = {
    description = "Xtreme Download Manager: download manager with multiple browser integrations";
    homepage = "https://xtremedownloadmanager.com/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    binaryNativeCode = true;
  };
})
