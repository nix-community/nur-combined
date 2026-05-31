# based on
# https://nixos.wiki/wiki/Node.js

{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  yarn-berry_4,
  electron,
  makeWrapper,
  jq,
  moreutils,
  ffmpeg,
}:

let
  yarn-berry = yarn-berry_4;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "losslesscut";
  version = "3.68.1";

  src = fetchFromGitHub {
    owner = "mifi";
    repo = "lossless-cut";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9eyfhJDQD3cYTZ3rdASS2fSloPa+/dvxSBmYQhKcPXo="; # src.hash
  };

  postPatch = ''
    # fix: Fatal: FFmpeg executable not found
    # adding ffmpeg to PATH in makeWrapper is not enough
    substituteInPlace src/main/ffmpeg.ts \
      --replace-fail \
        "const getFfmpegPath = () => getFfPath('ffmpeg');" \
        "const getFfmpegPath = () => '${ffmpeg}/bin/ffmpeg';" \
      --replace-fail \
        "const getFfprobePath = () => getFfPath('ffprobe');" \
        "const getFfprobePath = () => '${ffmpeg}/bin/ffprobe';"

    # remove checking for updates
    # fix:
    # info: Current version 3.68.1
    # info: Newest version 3.68.0
    # setting `enableUpdateCheck: false` in configStore.ts seems to have no effect
    # so we also patch `checkNewVersion()`
    substituteInPlace src/main/configStore.ts \
      --replace-fail \
        'enableUpdateCheck: true' \
        'enableUpdateCheck: false'
    substituteInPlace src/main/index.ts \
      --replace-fail \
        'newVersion = await checkNewVersion();' \
        'newVersion = "${finalAttrs.version}"; // newVersion = await checkNewVersion();'

    # remove propaganda
    # fix https://github.com/mifi/lossless-cut/issues/1055
    substituteInPlace src/renderer/src/mifi.ts \
      --replace-fail \
        'function loadMifiLink() {' \
        'function loadMifiLink() { return undefined;'

    # fix path to locales
    substituteInPlace src/main/i18nCommon.ts \
      --replace-fail \
        "return join('locales', subPath);" \
        "return join('$out/opt/losslesscut/locales', subPath);"

    # FIXME Error: app.getSystemLocale() can only be called after app is ready
    # so maybe app.getLocale is just called too early?
    #
    # fix default locale
    # app.getLocale() always returns "en-US" (why?)
    # app.getSystemLocale() returns the locale from the `LANG` environment variable
    false &&
    substituteInPlace src/main/i18n.ts \
      --replace-fail \
        "app.getLocale()" \
        "app.getSystemLocale()"

    # add version to versions.json
    jq --arg v "${finalAttrs.version}" '
    if any(.[]; .version == $v)
    then .
    else . + [{version: $v}]
    end
    ' src/renderer/src/versions.json |
    sponge src/renderer/src/versions.json

    # set version in package.json
    jq \
      --arg v "${finalAttrs.version}" \
      '. * {"version":$v}' \
      package.json |
      sponge package.json

    # patch lockfile version 9 for yarn 4.14
    # TODO check the actual lockfile version
    # NOTE this is also done in update.sh
    echo "yarn version ${yarn-berry.version}"
    # builtins.compareVersions a b
    # +1: a > b
    #  0: a == b
    # -1: a < b
    ${if (builtins.compareVersions yarn-berry.version "4.14") != -1 then "" else ''
    # yarn-berry.version < 4.14
    echo "not patching lockfile version 9 for yarn ${yarn-berry.version}"
    echo "error: this build requires yarn >=4.14"
    exit 1
    ''}
    # yarn-berry.version >= 4.14
    # yarn 4.14 requires lockfile version 9
    echo "patching lockfile version 9 for yarn ${yarn-berry.version}"
    sed -i '1,5 s/version: 8$/version: 9/' yarn.lock
  '';

  nativeBuildInputs = [
    nodejs
    yarn-berry
    yarn-berry.yarnBerryConfigHook
    electron
    makeWrapper
    jq
    moreutils # sponge
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  buildPhase = ''
    runHook preBuild

    # write build files to out/
    # yarn generate-icon && electron-vite build
    npm run build

    # fix: TypeError: Invalid Version
    # initialLastAppVersion="0.0" makes semver throw at
    # const matchingVersions = useMemo(() => versions
    #   .filter(({ version }) => semver.gt(version, initialLastAppVersion) && semver.lte(version, appVersion))
    #   .sort(({ version: a }, { version: b }) => semver.compare(b, a)), [initialLastAppVersion]);
    npm run postinstall

    use_electron_builder=false # 113 MB
    # use_electron_builder=true # 121 MB

    if $use_electron_builder; then
    cp -r --no-preserve=owner,mode ${electron.dist} electron-dist
    #     -c.asarUnpack="**/*.node" \
    npm exec electron-builder -- \
        --dir \
        -c.npmRebuild=true \
        -c.electronDist=electron-dist \
        -c.electronVersion=${electron.version}
    fi

    sed -i -E "s|^Exec=.*|Exec=$out/bin/losslesscut|" no.mifi.losslesscut.desktop

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/losslesscut

    cp -v package.json $out/opt/losslesscut

    cp -r locales $out/opt/losslesscut



    if $use_electron_builder; then

    cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/opt/losslesscut

    makeWrapper ${lib.getExe electron} $out/bin/losslesscut \
        --add-flags $out/opt/losslesscut/resources/app.asar \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
        --set-default ELECTRON_IS_DEV 0 \
        --prefix PATH : ${ffmpeg}/bin \
        --inherit-argv0

    else

    # use_electron_builder=false

    cp -r out $out/opt/losslesscut

    # remove devDependencies and optionalDependencies from node_modules
    # prune node_modules from 917M to 83M
    # # npm prune --omit=dev --omit=optional --verbose --debug --offline
    # but we have no package-lock.json, so "npm prune" requires internet access
    # and "yarn prune" does not exist
    # fix: implement "npm prune" in bash
    npmPruneArgs="--omit=dev --omit=optional"
    echo pruning node_modules
    mkdir node_modules_prod
    # +15: also remove prefix "e/node_modules/"
    npm ls --all --parseable $npmPruneArgs |
    tail -n+2 |
    cut -c$((''${#PWD}+15))- |
    while read -r pkg
    do
        # pkg: @some/package
        src="node_modules/$pkg"
        dst="node_modules_prod/$pkg"
        # echo "> cp -r $src $dst"
        mkdir -p "''${dst%/*}"
        cp -a "$src" "$dst"
    done

    # install node_modules
    cp -r node_modules_prod $out/opt/losslesscut/node_modules

    makeWrapper ${lib.getExe electron} $out/bin/losslesscut \
        --add-flags $out/opt/losslesscut \
        --prefix PATH : ${ffmpeg}/bin \
        --inherit-argv0

    fi



    mkdir -p $out/share/icons/hicolor/512x512/apps
    cp -v icon-build/app-512.png $out/share/icons/hicolor/512x512/apps/no.mifi.losslesscut.png

    mkdir -p $out/share/applications
    cp -v no.mifi.losslesscut.desktop $out/share/applications

    runHook postInstall
  '';

  missingHashes = ./missing-hashes.json;

  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes;
    inherit (finalAttrs) postPatch;
    nativeBuildInputs = [
      jq
      moreutils # sponge
      yarn-berry.yarn-berry-fetcher
    ];
    hash = "sha256-o0u9dAoo0sTEV+kjQg8TjRNAIcx8fqfk79HsDwAXriA="; # offlineCache.hash
  };

  meta = {
    description = "The swiss army knife of lossless video/audio editing";
    homepage = "https://github.com/mifi/lossless-cut";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "losslesscut";
    platforms = lib.platforms.all;
  };
})
