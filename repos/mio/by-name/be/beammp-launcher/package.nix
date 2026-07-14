{
  stdenv,
  fetchFromGitHub,
  lib,
  copyDesktopItems,
  installShellFiles,
  makeDesktopItem,

  cmake,
  curl,
  httplib,
  nlohmann_json,
  openssl,

  # https://gist.github.com/CMCDragonkai/1ae4f4b5edeb021ca7bb1d271caca999
  # https://github.com/BeamMP/BeamMP-Launcher/issues/186
  cacert_3108,
  makeBinaryWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "beammp-launcher";
  version = if stdenv.isDarwin then "2.7.0-unstable-20260111" else "2.8.0";

  src = fetchFromGitHub (
    if stdenv.isDarwin then
      {
        # Darwin support from https://github.com/BeamMP/BeamMP-Launcher/pull/221
        owner = "enzofrnt";
        repo = "BeamMP-Launcher";
        rev = "76da51872e2cc53912c3763890b2ea8585c51813";
        hash = "sha256-YfwhIiQqxSU63ZAbupUgv+7WeZlyJAPwkv3O3bM1Hyk=";
        fetchSubmodules = true;
      }
    else
      {
        owner = "BeamMP";
        repo = "BeamMP-Launcher";
        tag = "v${finalAttrs.version}";
        hash = "sha256-xg6lHsfIYRC9OxrI+A7MXYCxGbZrGHb/9gR7Dno6Pwk=";
      }
  );

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ]
  ++ lib.optionals (!stdenv.isDarwin) [
    copyDesktopItems
    installShellFiles
  ]
  ++ [
    makeBinaryWrapper
  ];

  buildInputs = [
    curl
    httplib
    nlohmann_json
    openssl
  ];

  desktopItems = lib.optionals (!stdenv.isDarwin) [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "Launcher for the BeamMP mod for BeamNG.drive";
      desktopName = "BeamMP-Launcher";
      exec = "BeamMP-Launcher";
      name = "BeamMP-Launcher";
      terminal = true;
    })
  ];

  installPhase = ''
    runHook preInstall
  ''
  + (
    if stdenv.isDarwin then
      ''
        mkdir -p $out/Applications/BeamMP-Launcher.app/Contents/{MacOS,Resources}
        cp BeamMP-Launcher $out/Applications/BeamMP-Launcher.app/Contents/MacOS/

        # Create Info.plist
        cat > $out/Applications/BeamMP-Launcher.app/Contents/Info.plist <<EOF
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleExecutable</key>
          <string>BeamMP-Launcher</string>
          <key>CFBundleIdentifier</key>
          <string>com.beammp.launcher</string>
          <key>CFBundleName</key>
          <string>BeamMP-Launcher</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
          <key>CFBundleVersion</key>
          <string>${finalAttrs.version}</string>
        </dict>
        </plist>
        EOF
      ''
    else
      ''
        installBin "BeamMP-Launcher"
        copyDesktopItems
      ''
  )
  + ''
    runHook postInstall
  '';

  postFixup =
    lib.optionalString stdenv.isDarwin ''
      mkdir -p $out/bin
      makeWrapper $out/Applications/BeamMP-Launcher.app/Contents/MacOS/BeamMP-Launcher $out/bin/BeamMP-Launcher \
        --set SSL_CERT_FILE "${cacert_3108}/etc/ssl/certs/ca-bundle.crt"
    ''
    + lib.optionalString (!stdenv.isDarwin) ''
      wrapProgram $out/bin/BeamMP-Launcher \
        --set SSL_CERT_FILE "${cacert_3108}/etc/ssl/certs/ca-bundle.crt"
    '';

  meta = {
    description = "Launcher for the BeamMP mod for BeamNG.drive";
    homepage = "https://github.com/BeamMP/BeamMP-Launcher";
    license = lib.licenses.agpl3Only;
    mainProgram = "BeamMP-Launcher";
    maintainers = with lib.maintainers; [
      Andy3153
      mochienya
    ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
