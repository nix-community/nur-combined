{
  rustPlatform,
  fetchFromGitHub,
  lib,
  llvmPackages,
  pkg-config,
  wrapGAppsHook4,
  desktop-file-utils,
  gtk4,
  pipewire,
  coreutils,
  pulseaudio,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pw-duck";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "geri1701";
    repo = "pw-duck";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7uQl9x924hqkjrGyqprcs6991Vnu5F7kdJmAJSscBag=";
  };

  cargoHash = "sha256-xmmayGuGwfHLLdtLO3QTXoMFJ7s6oLRTz1VM70gT34M=";
  buildFeatures = [ "gui" ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
    llvmPackages.libclang
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    gtk4
    pipewire
  ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : ${
      lib.makeBinPath [
        coreutils
        pipewire
        pulseaudio
      ]
    })
  '';

  postInstall = ''
    install -Dm644 assets/applications/pw-duck.desktop \
      $out/share/applications/pw-duck.desktop
    desktop-file-validate $out/share/applications/pw-duck.desktop

    mkdir -p $out/share/icons
    cp -r assets/icons/hicolor $out/share/icons/hicolor

    install -Dm644 README.md $out/share/doc/pw-duck/README.md
    install -Dm644 LICENSE $out/share/doc/pw-duck/LICENSE
  '';

  meta = {
    description = "Linux tray app that ducks non-voice audio while remote voice is active";
    license = lib.licenses.mit;
    mainProgram = "pw-duck";
    platforms = lib.platforms.linux;
  };
})
