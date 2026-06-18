{
  lib,
  fetchFromGitHub,
  stdenv,
  yarn-berry_4,
  nodejs_24,
  electron_42,
  makeWrapper,
  ffmpeg-headless,
}:
let
  yarn-berry = yarn-berry_4;
  nodejs = nodejs_24;
  electron = electron_42;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "losslesscut";
  version = "3.69.0";

  src = fetchFromGitHub {
    owner = "mifi";
    repo = "lossless-cut";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VNG23I5o9FjoFbiF6FyOG/g72XrF4FloIyd08zIKQRU=";
  };

  patches = [
    ./undev.patch
    ./yarn-4.14-support.patch
    ./stub-load-mifi.patch
  ];

  postPatch = ''
    for f in src/main/ffmpeg.ts src/main/i18nCommon.ts; do
      substituteInPlace "$f" \
        --subst-var-by losslesscut_resources_path $out/share/losslesscut
    done
  '';

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    ELECTRON_OVERRIDE_DIST_PATH = electron.dist;
    NODE_ENV = "production";
  };

  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    yarn-berry.yarnBerryConfigHook
    yarn-berry
    makeWrapper
  ];

  missingHashes = ./missing-hashes.json;
  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes patches;
    hash = "sha256-ioTQKZrT0lFnlmjVJL/kS5yP+oCw1GUZx0LWK2BqBq0=";
  };

  postConfigure = ''
    cp -r ${electron.dist} electron-dist
    chmod u+w -R electron-dist
  '';

  buildPhase = ''
    runHook preBuild

    yarn build

    yarn electron-builder \
      --dir \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/losslesscut

    cp -a dist/*-unpacked/resources $out/share/losslesscut

    ln -s -t $out/share/losslesscut/ ${lib.getExe' ffmpeg-headless "ffmpeg"} ${lib.getExe' ffmpeg-headless "ffprobe"}

    makeWrapper ${lib.getExe electron} $out/bin/losslesscut \
      --set-default ELECTRON_IS_DEV 0 \
      --add-flags $out/share/losslesscut/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    runHook postInstall
  '';

  meta = {
    description = "The swiss army knife of lossless video/audio editing";
    homepage = "https://mifi.no/losslesscut/";
    license = lib.licenses.gpl2Only;
    mainProgram = "losslesscut";
    platforms = lib.platforms.linux;
  };
})
