{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  electron,
  pkg-config,
  libusb1,
  udev,
  makeWrapper,
  nix-update-script,
}:

let
  pname = "nanokvm-usb";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "sipeed";
    repo = "NanoKVM-USB";
    rev = "b7694196081cf5e9699d59e2e2a2c6ac48e8dcd1";
    hash = "sha256-z0Sk7kTYTu7qP4j/7DJ1lFvGry/eH4bAfLH/u1RHSTE=";
  };

  sourceRoot = "${src.name}/desktop";

  # pnpm store (vendor) for fully offline install.
  pnpmDeps = pnpm.fetchDeps {
    inherit
      pname
      version
      src
      sourceRoot
      ;
    fetcherVersion = 2;
    hash = "sha256-IdWAenyo4CKTv+q/Aqp3QrbElU8D1iOA7bJE9GC0CqA=";
  };

in
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    sourceRoot
    ;

  nativeBuildInputs = [
    pnpm
    nodejs
    pkg-config
    makeWrapper
  ];

  buildInputs = lib.optionals stdenv.isLinux [
    libusb1
    udev
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  # Build the frontend / electron main bundle (electron-vite).
  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    pnpm config set store-dir "${pnpmDeps}"
    pnpm install --frozen-lockfile --offline
    pnpm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Verify build output exists
    if [ ! -d out ]; then
      echo "ERROR: expected build output directory 'out' not found"
      exit 1
    fi

    ${lib.optionalString stdenv.isDarwin ''
      # Create macOS .app bundle by reusing packaged Electron.
      mkdir -p $out/Applications
      cp -R ${electron}/Applications/Electron.app $out/Applications/NanoKVM-USB.app

      # Make the copied files writable since they come from read-only Nix store
      chmod -R u+w $out/Applications/NanoKVM-USB.app

      appContents="$out/Applications/NanoKVM-USB.app/Contents"
      resourcesDir="$appContents/Resources"

      # Remove default Electron app and prepare for our app
      rm -rf "$resourcesDir/default_app.asar" "$resourcesDir/electron.icns" "$resourcesDir/app"
      mkdir -p "$resourcesDir/app"

      # Copy our application files
      cp -r out node_modules package.json "$resourcesDir/app/"

      # Copy update configuration
      cp dev-app-update.yml "$resourcesDir/app-update.yml"

      # Patch Info.plist to reflect new app identity
      infoPlist="$appContents/Info.plist"
      substituteInPlace "$infoPlist" \
        --replace-fail "<string>Electron</string>" "<string>NanoKVM-USB</string>" \
        --replace-fail "<string>com.github.Electron</string>" "<string>org.sipeed.nanokvm-usb</string>"

      # Rename the executable to match CFBundleExecutable in Info.plist
      mv "$appContents/MacOS/Electron" "$appContents/MacOS/NanoKVM-USB"

      # Add icon
      cp build/icon.icns "$resourcesDir/NanoKVM-USB.icns"
        substituteInPlace "$infoPlist" \
          --replace-fail "electron.icns" "NanoKVM-USB.icns"

      # Provide CLI launcher
      mkdir -p $out/bin
      makeWrapper "$appContents/MacOS/NanoKVM-USB" "$out/bin/${pname}" \
        --set ELECTRON_DISABLE_SECURITY_WARNINGS "true"
    ''}

    ${lib.optionalString stdenv.isLinux ''
      # Linux installation: copy payload and wrap electron
      mkdir -p $out/opt/${pname}
      cp -r out node_modules package.json $out/opt/${pname}/

      mkdir -p $out/bin
      makeWrapper ${electron}/bin/electron $out/bin/${pname} \
        --add-flags "$out/opt/${pname}/out/main/index.js" \
        --set ELECTRON_DISABLE_SECURITY_WARNINGS "true"
    ''}

    runHook postInstall
  '';

  propagatedBuildInputs = [ electron ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "NanoKVM-USB Desktop (Electron + React client)";
    homepage = "https://github.com/sipeed/NanoKVM-USB";
    license = licenses.gpl3Only;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = pname;
    maintainers = [ maintainers.codgician ];
  };
}
