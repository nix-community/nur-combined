{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,

  alsa-lib,
  dbus,
  libxcb,
  libxkbcommon,
  openssl,
  vulkan-loader,
  wayland,

  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,

  apple-sdk_15,

  jdk21,
  jdk17,
  jdk8,
  jdks ? [
    jdk21
    jdk17
    jdk8
  ],
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pandora-launcher";
  version = "2.7.3";

  src = fetchFromGitHub {
    owner = "Moulberry";
    repo = "PandoraLauncher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pdeKtN/Zv97LGX4bscR8DwNzHx/Yk15ckDM7MP7oDgg=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    dbus
    libxcb
    libxkbcommon
    wayland
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_15
  ];

  buildFeatures = lib.optionals stdenv.hostPlatform.isDarwin [ "gpui/runtime_shaders" ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  cargoHash = "sha256-e2QZnwv8Wl4rr+4wCTWhJu9Xq8ZFgJ4iArLc7nRLUuM=";

  doCheck = false;

  desktopItems = lib.singleton (makeDesktopItem {
    name = "com.moulberry.pandoralauncher";
    desktopName = "Pandora Launcher";
    genericName = "Unofficial Minecraft Launcher";
    exec = "pandora_launcher";
    icon = "pandora_launcher";
  });

  postInstall = ''
    install -Dm444 package/windows_icons/icon_256x256.png $out/share/icons/hicolor/256x256/apps/pandora_launcher.png
    wrapProgram $out/bin/pandora_launcher \
      --set-default FORCE_EXTERNAL_JAVA "${lib.concatStringsSep ":" jdks}" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath ([ vulkan-loader ] ++ lib.optionals stdenv.hostPlatform.isLinux [ wayland ])
      }"
  '';

  meta = {
    description = "Pandora is a modern Minecraft launcher that balances ease-of-use with powerful instance management features";
    homepage = "https://github.com/Moulberry/PandoraLauncher";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "pandora_launcher";
  };
})
