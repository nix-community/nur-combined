# Linux binary packaging:
# https://github.com/NixOS/nixpkgs/pull/551713/files
{
  lib,
  stdenv,
  callPackage,
  autoPatchelfHook,
  dpkg,
  makeShellWrapper,
  python3,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libgbm,
  libusb1,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  openssl,
  pango,
  qt6,
  systemdLibs,
  tpm2-tss,
  bubblewrap,
  coreutils,
  gitMinimal,
  libGL,
  libnotify,
  libpulseaudio,
  libsecret,
  lsb-release,
  pipewire,
  ripgrep,
  vulkan-loader,
  wayland,
  xdg-utils,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  source ? callPackage ./source.nix { },
  componentSources ? callPackage ./component-sources.nix { inherit source; },
  cua-node ? callPackage ./cua-node.nix { src = componentSources.cua_node; },
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  pname = "chatgpt-unwrapped";
  inherit (source) version src;

  strictDeps = true;
  sourceRoot = "root";
  dontBuild = true;
  dontStrip = true;
  dontWrapGApps = true;
  dontWrapQtApps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeShellWrapper
    python3
    qt6.wrapQtAppsHook
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libgbm
    libusb1
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    openssl
    pango
    qt6.qtbase
    stdenv.cc.cc.lib
    systemdLibs
    tpm2-tss
  ];

  # Electron loads these with dlopen, so autoPatchelf cannot infer them.
  runtimeDependencies = map lib.getLib [
    libGL
    libnotify
    libpulseaudio
    libsecret
    pipewire
    vulkan-loader
    wayland
  ];

  postPatch = ''
    python3 ${./patch-asar.py} usr/lib/chatgpt/resources/app.asar

    # Components are patched independently so their paths do not follow this version.
    rm -r usr/lib/chatgpt/resources/{cua_node,tectonic}

    rm usr/lib/chatgpt/resources/rg

    # Keep only the Linux x86_64 glibc prebuilds and the Qt 6 shim.
    rm usr/lib/chatgpt/libqt5_shim.so
    python3 ${./components.py} prune usr/lib/chatgpt/resources
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a usr/. "$out/"

    runHook postInstall
  '';

  postFixup = ''
    # autoPatchelf skips symlinks, keeping the components' ELF paths independent.
    ln -s ${cua-node} "$out/lib/chatgpt/resources/cua_node"
    ln -s ${componentSources.tectonic} "$out/lib/chatgpt/resources/tectonic"

    ln -s ${lib.getExe ripgrep} "$out/lib/chatgpt/resources/rg"

    # The upstream launcher needs dirname/readlink before PATH is set.
    rm "$out/bin/chatgpt"
    ln -s ../lib/chatgpt/ChatGPT "$out/bin/chatgpt"
    # Host Qt plugins may have a different private ABI than the bundled shim.
    # https://github.com/numtide/llm-agents.nix/commit/322f1007f0de4369f0bff1f53e3725e23b86883f
    wrapProgramShell "$out/lib/chatgpt/ChatGPT" \
      --unset QT_PLUGIN_PATH \
      --unset QT_QPA_PLATFORM_PLUGIN_PATH \
      "''${gappsWrapperArgs[@]}" \
      "''${qtWrapperArgs[@]}" \
      --prefix PATH : ${
        lib.makeBinPath [
          bubblewrap
          coreutils
          gitMinimal
          lsb-release
          xdg-utils
        ]
      }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  versionCheckKeepEnvironment = [ "HOME" ];

  passthru = source // {
    components = {
      cua_node = cua-node;
      inherit (componentSources) tectonic;
    };
    updateScript = [
      "${python3}/bin/python3"
      "${./.}/update.py"
      "--dpkg-deb"
      "${dpkg}/bin/dpkg-deb"
      "--source-file"
      "pkgs/chatgpt/source.nix"
    ];
  };

  meta = {
    description = "Desktop application for ChatGPT and Codex";
    homepage = "https://developers.openai.com/codex/app";
    changelog = "https://learn.chatgpt.com/docs/changelog";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ merrkry ];
    mainProgram = "chatgpt";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
