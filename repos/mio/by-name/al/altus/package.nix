{
  lib,
  stdenv,
  fetchFromGitHub,
  jq,
  makeDesktopItem,
  copyDesktopItems,
  makeBinaryWrapper,
  electron_43,
  yarn-berry_4,
  nodejs,
  zip,
  writableTmpDirAsHomeHook,
  writeShellApplication,
  nix-update-script,
}:

let
  electron = electron_43;
  yarn-berry = yarn-berry_4;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "altus";
  version = "5.8.4";

  src = fetchFromGitHub {
    owner = "amanharwara";
    repo = "altus";
    tag = finalAttrs.version;
    hash = "sha256-7i+7lDQY3GkeBs8t05PH2FCuusBHowgjUmwe9L+Y2l0=";
  };

  missingHashes = ./missing-hashes.json;

  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes;
    hash = "sha256-UpVQyzeEcfCn18j3yz0SvQPR1kwfc2bDZu/unZa02ag=";
  };

  nativeBuildInputs = [
    jq
    makeBinaryWrapper
    copyDesktopItems
    yarn-berry
    yarn-berry.yarnBerryConfigHook
    writableTmpDirAsHomeHook
    nodejs
    (nodejs.python.withPackages (ps: with ps; [ setuptools ]))
    zip
  ];
  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  };

  buildPhase = ''
        runHook preBuild

        electron_ver=$(jq -r '.devDependencies.electron' package.json | tr -d '^~')
        arch="${if stdenv.hostPlatform.isAarch64 then "arm64" else "x64"}"
        zip_name="electron-v''${electron_ver}-linux-$arch.zip"

        cp -r "${electron.dist}" electron-dist
        chmod -R u+w electron-dist
        pushd electron-dist
        zip -0Xqr "../$zip_name" .
        popd
        rm -rf electron-dist

        export ELECTRON_OVERRIDE_DIST_PATH="$HOME/.electron-dist"
        mkdir -p "$ELECTRON_OVERRIDE_DIST_PATH"
        cp -r "${electron.dist}/." "$ELECTRON_OVERRIDE_DIST_PATH/"
        chmod -R u+w "$ELECTRON_OVERRIDE_DIST_PATH"

        # Mock @electron/get completely to prevent network requests
        # and return our locally built zip file.
        for dir in $(find node_modules -type d -name "@electron"); do
          if [ -d "$dir/get" ]; then
            rm -rf "$dir/get"
            mkdir -p "$dir/get"
            cat <<EOF > "$dir/get/index.js"
    // ES module: @electron/packager imports getHostArch as a named export,
    // which Node's CJS interop cannot see on a module.exports Proxy.
    const zip = process.cwd() + "/$zip_name";
    export const initializeProxy = () => {};
    export const downloadArtifact = async () => zip;
    export const downloadArtifactSync = () => zip;
    export const download = async () => zip;
    export const getHostArch = () => "$arch";
    export const getCachePath = () => process.cwd();
    export default {
      initializeProxy,
      downloadArtifact,
      downloadArtifactSync,
      download,
      getHostArch,
      getCachePath
    };
    EOF
            echo "{ \"name\": \"@electron/get\", \"version\": \"2.0.0\", \"type\": \"module\", \"main\": \"index.js\", \"exports\": { \".\": \"./index.js\", \"./package.json\": \"./package.json\" } }" > "$dir/get/package.json"
          fi
        done

        # Remove old packager.js patches that are brittle
        # and instead configure electronZipDir

        substituteInPlace forge.config.ts \
          --replace-warn "packagerConfig: {" "packagerConfig: { derefSymlinks: false, prune: false, ignore: (file) => { if (!file) return false; if (file.includes('node_modules') || file.includes('.yarn') || file.includes('.git') || file.includes('.cache')) return true; return false; }, " \
          --replace-warn "rebuildConfig: {}," ""

        cat <<EOF > node_modules/@electron/packager/dist/unzip.js
    import { execSync } from 'node:child_process';
    export async function extractElectronZip(zipPath, targetDir) {
        execSync('cp -r ' + process.env.ELECTRON_OVERRIDE_DIST_PATH + '/. ' + targetDir);
    }
    EOF

        yarn run package

        runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    app_dir="out/Altus-linux-x64"
    if [ -d "out/Altus-linux-arm64" ]; then
      app_dir="out/Altus-linux-arm64"
    fi

    mkdir -p "$out/opt/altus"
    cp -r "$app_dir/resources" "$out/opt/altus/"
    rm -f "$out/opt/altus/resources/app"/*.zip

    install -Dm644 public/assets/icons/icon.png \
      "$out/share/icons/hicolor/256x256/apps/altus.png"

    makeWrapper ${lib.getExe electron} "$out/bin/altus" \
      --add-flags "$out/opt/altus/resources/app" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "altus";
      desktopName = "Altus";
      comment = "Desktop client for WhatsApp Web with themes and multiple account support";
      exec = "altus";
      icon = "altus";
      categories = [
        "Network"
        "Chat"
      ];
    })
  ];

  passthru.updateScript = writeShellApplication {
    name = "update-altus";
    text = ''
      export UPDATE_NIX_ATTR_PATH="altus"
      exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
    '';
  };

  meta = {
    description = "Desktop client for WhatsApp Web with themes and multiple account support";
    homepage = "https://github.com/amanharwara/altus";
    license = lib.licenses.gpl3Only;
    mainProgram = "altus";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
