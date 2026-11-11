{
  lib,
  rustPlatform,
  fetchFromGitHub,
  withGui ? true,
  makeWrapper,
  wayland,
  libxkbcommon,
  vulkan-loader,
  pkg-config,
  openssl,
  sqlite,
  aws-lc,
}:

rustPlatform.buildRustPackage rec {
  pname = "bb-imager-rs";
  version = "1.0.20";

  src = fetchFromGitHub {
    owner = "beagleboard";
    repo = "bb-imager-rs";
    tag = "${version}";
    hash = "sha256-lLBswNcwR0DSicMoyBqTmUvjqu6NwQrdiHrKXj8SAqA=";
  };

  cargoHash = "sha256-oef7BeQsXHWj+Q50IdRnbFfUL7RPVf8DpatWq+pLHAI=";

  doCheck = false;

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    openssl
    sqlite
    aws-lc
  ];

  cargoBuildFlags = [
    "--bin"
    "bb-imager-cli"
  ]
  ++ lib.optionals withGui [
    "--bin"
    "bb-imager-gui"
  ];

  installPhase =
    let
      cargoTarget = rustPlatform.cargoInstallHook.targetSubdirectory;
    in
    ''
      runHook preInstall
      install -D target/${cargoTarget}/release/bb-imager-cli $out/bin/bb-imager-cli
    ''
    + lib.optionalString withGui ''
      install -D target/${cargoTarget}/release/bb-imager-gui $out/bin/bb-imager-gui
    ''
    + ''
      runHook postInstall
    '';

  postInstall = lib.optionalString withGui ''
    wrapProgram $out/bin/bb-imager-gui \
     --prefix LD_LIBRARY_PATH : "${
       lib.makeLibraryPath [
         wayland
         libxkbcommon
         vulkan-loader
       ]
     }"

    install -Dm644 \
      bb-imager-ui/assets/icons/icon.png \
      $out/share/icons/hicolor/128x128/apps/bb-imager.png
    install -Dm644 \
      bb-imager-gui/assets/packages/linux/BeagleBoardImager.desktop \
      $out/share/applications/BeagleBoardImager.desktop
  '';

  meta = {
    description = "BeagleBoard Imaging Utility";
    longDescription = ''
      A user-friendly tool for creating bootable media for Beagle devices.
    '';
    homepage = "https://github.com/beagleboard/bb-imager-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "bb-imager-cli";
  };
}
