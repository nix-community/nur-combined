{
  lib,
  rustPlatform,
  fetchFromGitHub,
  withGui ? true,
  makeWrapper,
  wayland,
  libxkbcommon,
  vulkan-loader,
}:

rustPlatform.buildRustPackage rec {
  pname = "bb-imager-rs";
  version = "0.0.14";

  src = fetchFromGitHub {
    owner = "beagleboard";
    repo = "bb-imager-rs";
    rev = "v${version}";
    hash = "sha256-6kMPWGdnl/nlZqELLA2tZ54edFmDwh4ZeuF18Ru35Ik=";
  };

  cargoHash = "sha256-+hXyUpFktUH44y5TB583gI6cfPqKH4GyX6Qun5tY1JE=";

  doCheck = false;

  nativeBuildInputs = [ makeWrapper ];

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
      bb-imager-gui/assets/icons/icon.png \
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
