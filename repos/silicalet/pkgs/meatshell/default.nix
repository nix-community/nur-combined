{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  fontconfig,
  freetype,
  gtk3,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  makeWrapper,
  nix-update-script,
  pkg-config,
  udev,
  versionCheckHook,
  wayland,
}:

let
  runtimeLibraries = [
    fontconfig
    freetype
    gtk3
    libGL
    libx11
    libxcb
    libxcursor
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    udev
    wayland
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "meatshell";
  version = "0.6.8";

  src = fetchFromGitHub {
    owner = "yituorou";
    repo = "meatshell";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GdCXJHcdP0z6Yo7cbgASgNiS2PFIW4mOtxs58QFZ1do=";
  };

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibraries;

  postInstall = ''
    install -Dm644 assets/meatshell.desktop \
      "$out/share/applications/meatshell.desktop"
    install -Dm644 assets/icon@512.png \
      "$out/share/icons/hicolor/512x512/apps/meatshell.png"
  '';

  postFixup = ''
    wrapProgram "$out/bin/meatshell" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}"
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight FinalShell-style SSH and terminal client";
    homepage = "https://github.com/yituorou/meatshell";
    changelog = "https://github.com/yituorou/meatshell/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "meatshell";
    platforms = lib.platforms.linux;
  };
})
