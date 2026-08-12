{
  fetchFromGitHub,
  fetchYarnDeps,
  fetchurl,
  fetchzip,
  google-chrome,
  jq,
  lib,
  makeWrapper,
  node-gyp,
  nodejs,
  pkg-config,
  python3,
  redis,
  runCommand,
  stdenv,
  socat,
  stevenblack-blocklist,
  vips,
  x11vnc,
  xvfb,
  yarnBuildHook,
  yarnConfigHook,
}:
let
  version = "1.14.0";
  rwp_version = "2.4.3";
  rwp = fetchzip {
    url = "https://registry.npmjs.org/replaywebpage/-/replaywebpage-${rwp_version}.tgz";
    hash = "sha256-S5bf3tp3pz880tgUz75dPjowK2G6tP2HvMxiPd+om5E=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "browsertrix-crawler";
  inherit version;
  src = fetchFromGitHub {
    owner = "webrecorder";
    repo = "browsertrix-crawler";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0tVR0pyKCIMFpKJ18NnRa+3Z6cEEpTs5fRucelAIZ00=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-0QCwgm+AJ9bwPftbA4DmTeLMOTwhCqOtoGVYr7EjYn8=";
  };

  env.yarnBuildScript = "tsc";
  env.PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = true;
  env.SHARP_FORCE_GLOBAL_LIBVIPS = 1;

  strictDeps = true;

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
    node-gyp
    makeWrapper
    pkg-config
    python3
  ];

  buildInputs = [
    vips
  ];

  patchPhase = ''
    substituteInPlace src/create-login-profile.ts \
      --replace-fail 'default: "/crawls/profiles/profile.tar.gz"' 'default: "./profiles/profile.tar.gz"'
  '';

  preBuild = ''
    mkdir -p $HOME/.node-gyp/${nodejs.version}
    echo 9 > $HOME/.node-gyp/${nodejs.version}/installVersion
    ln -sfv ${nodejs}/include $HOME/.node-gyp/${nodejs.version}
    export npm_config_nodedir=${nodejs}

    pkg-config --modversion vips-cpp
    (cd node_modules/sharp && yarn --offline run install)
  '';

  installPhase = ''
    mkdir -pv $out/{bin,lib/node_modules/browsertrix-crawler/html/rwp}

    cp -rv ./* $out/lib/node_modules/browsertrix-crawler/

    cp ${rwp}/ui.js $out/lib/node_modules/browsertrix-crawler/html/rwp/ui.js
    cp ${rwp}/sw.js $out/lib/node_modules/browsertrix-crawler/html/rwp/sw.js
    cp ${rwp}/adblock/adblock.gz $out/lib/node_modules/browsertrix-crawler/html/rwp/adblock.gz
    grep '^0\.0\.0\.0 ' ${stevenblack-blocklist}/hosts \
      | awk '{ print $2; }' \
      | grep -v '0\.0\.0\.0\( \|$\)' \
      | ${lib.getExe jq} --raw-input --slurp 'split("\n")' \
        > $out/lib/node_modules/browsertrix-crawler/ad-hosts.json

    makeWrapper ${lib.getExe nodejs} $out/bin/browsertrix-crawl \
      --add-flag --experimental-global-webcrypto \
      --add-flag $out/lib/node_modules/browsertrix-crawler/dist/main.js \
      --prefix PATH : ${
        lib.makeBinPath [
          redis
          xvfb
        ]
      } \
      --set BROWSER_BIN ${lib.getExe google-chrome} \
      --set BROWSER_VERSION ${google-chrome.version} \
      --set-default GEOMETRY "1360x1020x16" \
      --set-default VNC_PASS "vncpassw0rd!" \
      --set-default DETACHED_CHILD_PROC "1"

    ln -s $out/bin/browsertrix-crawl $out/bin/browsertrix-qa

    makeWrapper ${lib.getExe nodejs} $out/bin/browsertrix-create-login-profile \
      --add-flag $out/lib/node_modules/browsertrix-crawler/dist/create-login-profile.js \
      --prefix PATH : ${
        lib.makeBinPath [
          socat
          x11vnc
          xvfb
        ]
      } \
      --set BROWSER_BIN ${lib.getExe google-chrome} \
      --set BROWSER_VERSION ${google-chrome.version} \
      --set-default GEOMETRY "1360x1020x16" \
      --set-default VNC_PASS "vncpassw0rd!" \
      --set-default DETACHED_CHILD_PROC "1"
  '';

  meta = {
    description = "A simplified browser-based crawling system";
    homepage = "https://crawler.docs.browsertrix.com";
    downloadPage = "https://github.com/webrecorder/browsertrix-crawler";
    # unfree due to google-chrome dependency
    license = [
      lib.licenses.agpl3Plus
      lib.licenses.unfree
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "browsertrix-crawl";
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
