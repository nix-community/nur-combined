{
  lib,
  rustPlatform,
  pkg-config,
  apple-sdk_14,
  stdenv,
  libxcb,
  libxkbcommon,
  wayland,
  vulkan-loader,
  libGL,
  desktopToDarwinBundle,
  makeWrapper,
  nerd-fonts,
  noto-fonts-color-emoji,
}:

rustPlatform.buildRustPackage {
  pname = "omnimux";
  version = "0.1.0";

  src = lib.cleanSource ./src;

  cargoLock = {
    lockFile = ./src/Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  buildInputs =
    lib.optionals stdenv.isDarwin [
      apple-sdk_14
    ]
    ++ lib.optionals stdenv.isLinux [
      libxcb
      libxkbcommon
      wayland
      vulkan-loader
      libGL
    ];

  # Install .desktop + icon on all platforms so Linux gets a launcher entry and
  # Darwin's desktopToDarwinBundle can generate $out/Applications/Omnimux.app.
  # Ship Nerd + emoji fonts for Starship / powerline prompts on Linux and macOS.
  postInstall = ''
    install -Dm444 ${./omnimux.desktop} $out/share/applications/omnimux.desktop
    install -Dm444 ${./omnimux.svg} $out/share/icons/hicolor/scalable/apps/omnimux.svg

    mkdir -p $out/share/omnimux/fonts
    cp -L ${nerd-fonts.symbols-only}/share/fonts/truetype/NerdFonts/Symbols/*.ttf \
      $out/share/omnimux/fonts/
    cp -L ${noto-fonts-color-emoji}/share/fonts/noto/NotoColorEmoji.ttf \
      $out/share/omnimux/fonts/
  '';

  postFixup =
    lib.optionalString stdenv.isLinux ''
      patchelf $out/bin/omnimux --add-rpath ${
        lib.makeLibraryPath [
          wayland
          vulkan-loader
          libGL
          libxkbcommon
        ]
      }
    ''
    + ''
      wrapProgram $out/bin/omnimux \
        --set OMNIMUX_FONTS_DIR $out/share/omnimux/fonts
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      if [ -d "$out/Applications/Omnimux.app/Contents/Resources" ]; then
        mkdir -p "$out/Applications/Omnimux.app/Contents/Resources/fonts"
        cp -L $out/share/omnimux/fonts/*.ttf \
          "$out/Applications/Omnimux.app/Contents/Resources/fonts/"
      fi
    '';

  meta = with lib; {
    description = "Omnimux - GPUI terminal multiplexer";
    homepage = "https://github.com/mio-19/omnimux";
    downloadPage = "https://github.com/mio-19/omnimux/releases/tag/rolling";
    license = licenses.mit;
    mainProgram = "omnimux";
    platforms = platforms.unix;
  };
}
