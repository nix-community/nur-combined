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
  fontconfig,
  freetype,
  desktopToDarwinBundle,
  makeWrapper,
  nerd-fonts,
  noto-fonts-color-emoji,
  hack-font,
  tmux,
  libiconv,
  fetchFromGitHub,
  fetchzip,
  applyPatches,
}:

let
  patchedAlacrittyTerminal = applyPatches {
    name = "alacritty_terminal-0.26.0-patched";
    src = fetchzip {
      url = "https://static.crates.io/crates/alacritty_terminal/alacritty_terminal-0.26.0.crate";
      hash = "sha256-L1u/wBu+kzDpnAtGnpPyL8nUx4wQELdOzInlYwml9rw=";
      extension = "tar.gz";
    };
    patches = [ ./patches/alacritty_terminal.patch ];
  };

  patchedGpuiPreLinux = applyPatches {
    name = "gpui-pre-linux-0.3.8-patched";
    src = fetchzip {
      url = "https://static.crates.io/crates/gpui-pre-linux/gpui-pre-linux-0.3.8.crate";
      hash = "sha256-TtGSoMKrW1JbTn6cmgwOLCX8cXXxr6meIkta0phI2vk=";
      extension = "tar.gz";
    };
    patches = [ ./patches/gpui-pre-linux.patch ];
  };

  patchedGpuiPreWgpu = applyPatches {
    name = "gpui-pre-wgpu-0.3.8-patched";
    src = fetchzip {
      url = "https://static.crates.io/crates/gpui-pre-wgpu/gpui-pre-wgpu-0.3.8.crate";
      hash = "sha256-/ZwKGDOTUtMO8zYy0ypYQ9mZnSjAYKyFSoWSJr1o5FM=";
      extension = "tar.gz";
    };
    patches = [ ./patches/gpui-pre-wgpu.patch ];
  };

  patchedGpuiPreMacos = applyPatches {
    name = "gpui-pre-macos-0.3.8-patched";
    src = fetchzip {
      url = "https://static.crates.io/crates/gpui-pre-macos/gpui-pre-macos-0.3.8.crate";
      hash = "sha256-ws9zEtgGWK73nhHW/e11Oa+seY2omqgnBLmje3fplZ4=";
      extension = "tar.gz";
    };
    patches = [ ./patches/gpui-pre-macos.patch ];
  };

  patchedGpuiTerminal = applyPatches {
    name = "gpui-terminal-patched";
    src = fetchFromGitHub {
      owner = "zortax";
      repo = "gpui-terminal";
      rev = "45c63e57181d27c260124a81c7e4b68a6b6e57b0";
      hash = "sha256-CTGjQWr1qZSzfgYvULuJ33n9SmWZaynvno9pZ570uaY=";
    };
    patches = [ ./patches/gpui-terminal.patch ];
  };
in
rustPlatform.buildRustPackage {
  pname = "omnimux";
  version = "0.1.0";

  src = lib.cleanSource ./src;

  cargoLock = {
    lockFile = ./src/Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  postUnpack = ''
    mkdir -p $sourceRoot/vendor
    cp -r ${patchedGpuiTerminal} $sourceRoot/vendor/gpui-terminal
    chmod -R u+w $sourceRoot/vendor/gpui-terminal
    cp -r ${patchedAlacrittyTerminal} $sourceRoot/vendor/alacritty_terminal
    chmod -R u+w $sourceRoot/vendor/alacritty_terminal
    cp -r ${patchedGpuiPreLinux} $sourceRoot/vendor/gpui-pre-linux
    chmod -R u+w $sourceRoot/vendor/gpui-pre-linux
    cp -r ${patchedGpuiPreWgpu} $sourceRoot/vendor/gpui-pre-wgpu
    chmod -R u+w $sourceRoot/vendor/gpui-pre-wgpu
    cp -r ${patchedGpuiPreMacos} $sourceRoot/vendor/gpui-pre-macos
    chmod -R u+w $sourceRoot/vendor/gpui-pre-macos
  '';

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  buildInputs =
    lib.optionals stdenv.hostPlatform.isDarwin [
      apple-sdk_14
      libiconv
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      libxcb
      libxkbcommon
      wayland
      vulkan-loader
      libGL
      # gpui-pre / zed-font-kit (font-kit feature on gpui-pre-platform)
      fontconfig
      freetype
    ];

  buildFeatures = lib.optionals stdenv.hostPlatform.isDarwin [
    "gpui-platform/runtime_shaders"
  ];

  # Install .desktop + icon on all platforms so Linux gets a launcher entry and
  # Darwin's desktopToDarwinBundle can generate $out/Applications/Omnimux.app.
  # Ship Nerd + emoji for Starship / powerline. On Linux also ship Hack as a
  # last-resort terminal face (GPUI ignores fontconfig's monospace alias).
  postInstall = ''
    install -Dm444 ${./omnimux.desktop} $out/share/applications/omnimux.desktop
    install -Dm444 ${./omnimux.svg} $out/share/icons/hicolor/scalable/apps/omnimux.svg

    mkdir -p $out/share/omnimux/fonts
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    cp -L ${hack-font}/share/fonts/truetype/Hack-*.ttf \
      $out/share/omnimux/fonts/
  ''
  + ''
    cp -L ${nerd-fonts.symbols-only}/share/fonts/truetype/NerdFonts/Symbols/*.ttf \
      $out/share/omnimux/fonts/
    cp -L ${noto-fonts-color-emoji}/share/fonts/noto/NotoColorEmoji.ttf \
      $out/share/omnimux/fonts/
  '';

  postFixup =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      patchelf $out/bin/omnimux --add-rpath ${
        lib.makeLibraryPath [
          wayland
          vulkan-loader
          libGL
          libxkbcommon
          fontconfig
          freetype
        ]
      }
    ''
    + ''
      wrapProgram $out/bin/omnimux \
        --set OMNIMUX_FONTS_DIR $out/share/omnimux/fonts \
        --prefix PATH : ${lib.makeBinPath [ tmux ]}
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
