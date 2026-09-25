{
  lib,
  stdenv,

  fetchFromGitHub,
  fetchYarnDeps,

  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  nodejs,
  yarn,
  yarnConfigHook,

  nwjs,
  streamlink,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "streamlink-twitch-gui";
  version = "2.5.3";

  src = fetchFromGitHub {
    owner = "streamlink";
    repo = "streamlink-twitch-gui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OfgGG5Vg6UO7tUpRWviC541WqLtLRivTtWqLf7Td3EQ=";
  };

  offlineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-i8rhWl6e0r0VhFZZElfdPpwCWCXwg0zMLhyFMe2QtqU=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    nodejs
    yarn
    yarnConfigHook
  ];

  # Upstream ships NW.js 0.83, where the legacy "nw1" window mode could still be
  # asked for. nixpkgs' nwjs is much newer and only has nw2, where
  # `--disable-features=nw2` leaves the window blank forever.
  postPatch = ''
    substituteInPlace src/app/package.json \
      --replace-fail " --disable-features=nw2" ""
  '';

  # `grunt build:prod` would also run the test suite, which wants a real browser;
  # these are the two tasks it does after that.
  buildPhase = ''
    runHook preBuild
    yarn --offline run grunt clean:tmp_prod webpack:prod
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"/share/${finalAttrs.pname}
    cp -a build/tmp/prod/. "$out"/share/${finalAttrs.pname}/
    # snoretoast, the windows-only notification provider
    rm -rf "$out"/share/${finalAttrs.pname}/bin

    for res in 16 32 48 64 128 256; do
      install -Dm644 \
        build/resources/icons/icon-"$res".png \
        "$out"/share/icons/hicolor/"$res"x"$res"/apps/${finalAttrs.pname}.png
    done
    install -Dm644 \
      build/resources/linux/${finalAttrs.pname}.appdata.xml \
      "$out"/share/metainfo/${finalAttrs.pname}.appdata.xml

    makeWrapper ${lib.getExe nwjs} "$out"/bin/${finalAttrs.pname} \
      --add-flags "$out/share/${finalAttrs.pname}" \
      --add-flags "--no-version-check" \
      --prefix PATH : ${lib.makeBinPath [ streamlink ]}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      exec = finalAttrs.pname;
      icon = finalAttrs.pname;
      desktopName = "Streamlink Twitch GUI";
      genericName = "Twitch.tv browser for Streamlink";
      categories = [
        "AudioVideo"
        "Network"
      ];
    })
  ];

  meta = {
    description = "Twitch.tv browser for Streamlink";
    longDescription = "Browse Twitch.tv and watch streams in your videoplayer of choice";
    homepage = "https://streamlink.github.io/streamlink-twitch-gui/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # the ember/webpack build pulls a lot from npm
      binaryBytecode
    ];
    mainProgram = "streamlink-twitch-gui";
    maintainers = [ lib.maintainers.shelvacu ];
    inherit (nwjs.meta) platforms;
  };
})
