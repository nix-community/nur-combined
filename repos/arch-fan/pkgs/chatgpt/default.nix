{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  perl,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libdrm,
  libgbm,
  libnotify,
  libpulseaudio,
  libsecret,
  libusb1,
  libxkbcommon,
  nspr,
  nss,
  pango,
  pipewire,
  qt5,
  qt6,
  systemd,
  wayland,
  xdg-utils,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
}:

stdenv.mkDerivation {

  pname = "chatgpt";
  version = "26.810.50856";

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_26.810.50856_amd64.deb";
    hash = "sha256-47R8EpjgHkoqpU8SDrFpg0xpEb0pUSK8Q+XNFkLBpLo=";
  };

  dontStrip = true;
  dontWrapGApps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    perl
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
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libdrm
    libgbm
    libnotify
    libpulseaudio
    libusb1
    libxkbcommon
    nspr
    nss
    pango
    pipewire
    stdenv.cc.cc.lib
    systemd
    wayland
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
  ];

  # Electron loads these at runtime rather than linking them directly. Put
  # them on each ELF object's RPATH without leaking a broad LD_LIBRARY_PATH
  # into Electron's Node and Chromium children.
  runtimeDependencies = [
    libGL
    libgbm
    libsecret
    pipewire
    wayland
  ];

  # The archive includes musl, glibc, and Android prebuilds for a few Node
  # modules. NixOS uses the glibc variants, so the other runtimes are
  # intentionally absent.
  # The Qt shims are optional and selected dynamically, so autoPatchelf cannot
  # resolve both of their runtimes during its direct dependency pass. Their
  # version-specific RPATHs are added in postFixup below.
  autoPatchelfIgnoreMissingDeps = [
    "libc++_shared.so"
    "libc.musl-x86_64.so.1"
    "liblog.so"
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/lib" "$out/share"
    cp -r usr/lib/chatgpt "$out/lib/"
    cp -r usr/share/applications usr/share/pixmaps "$out/share/"
    ln -s ../lib/chatgpt/codex-launcher "$out/bin/chatgpt"

    # @parcel/watcher uses detect-libc in a named worker. Its process.report
    # fallback trips a CFI guard in the bundled Owl/Electron runtime on NixOS.
    # Keep the replacement the same length so the asar offsets remain valid;
    # detect-libc will use its ELF/filesystem/ldd fallbacks instead.
    appAsar="$out/lib/chatgpt/resources/app.asar"
    grep -aFq "isLinux() && process.report" "$appAsar"
    sed -i 's/isLinux() \&\& process\.report/false \/\* nix:skip report \*\//' "$appAsar"
    ! grep -aFq "isLinux() && process.report" "$appAsar"
    grep -aFq "false /* nix:skip report */" "$appAsar"

    # The app materializes bundled plugins in ~/.codex and rewrites selected
    # manifests there. Node's fs.cp preserves the Nix store's read-only modes,
    # so copy with coreutils and make only the user-owned destination writable.
    # Keep the replacement byte-length-preserving so ASAR offsets stay valid.
    original='async function Mne(e,t){if(S.default.platform===`darwin`){await lne(`/usr/bin/ditto`,[`--noqtn`,e,t]);return}if(S.default.platform!==`win32`){await y.default.cp(e,t,{recursive:!0,verbatimSymlinks:!0});return}let{copyDirectoryAllowDecryptedDestinationOnEncryptionFailure:n}=await Promise.resolve().then(()=>require("./windows-file-copy-Bw9CB6bJ.js"));await n({copy:()=>y.default.cp(e,t,{recursive:!0,verbatimSymlinks:!0}),destination:t,source:e})}'
    replacement='async function Mne(e,t){let r=S.default.platform;if(r===`darwin`){await lne(`/usr/bin/ditto`,[`--noqtn`,e,t]);return}if(r!==`win32`){await lne(`cp`,[`-r`,e+`/.`,t]);await lne(`chmod`,[`-R`,`u+w`,t]);return}let{copyDirectoryAllowDecryptedDestinationOnEncryptionFailure:n}=await Promise.resolve().then(()=>require("./windows-file-copy-Bw9CB6bJ.js"));await n({copy:()=>y.default.cp(e,t,{recursive:!0,verbatimSymlinks:!0}),destination:t,source:e})}  '

    if [ "''${#original}" -ne "''${#replacement}" ]; then
      echo "ChatGPT bundled-plugin ASAR patch changed byte length" >&2
      exit 1
    fi

    grep -aFq "$original" "$appAsar"
    export original replacement
    perl -0pi -e 'BEGIN { $from = $ENV{original}; $to = $ENV{replacement} } s/\Q$from\E/$to/' "$appAsar"
    ! grep -aFq "$original" "$appAsar"
    grep -aFq 'await lne(`chmod`,[`-R`,`u+w`,t])' "$appAsar"

    wrapProgram "$out/lib/chatgpt/ChatGPT" \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          xdg-utils
        ]
      }

    runHook postInstall
  '';

  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath [ qt5.qtbase ]} \
      "$out/lib/chatgpt/libqt5_shim.so"
    patchelf --add-rpath ${lib.makeLibraryPath [ qt6.qtbase ]} \
      "$out/lib/chatgpt/libqt6_shim.so"
  '';

  passthru.category = "AI Coding Agents";

  meta = with lib; {
    description = "Desktop application for ChatGPT and Codex";
    homepage = "https://developers.openai.com/codex/app";
    changelog = "https://learn.chatgpt.com/docs/changelog";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "chatgpt";
    platforms = [ "x86_64-linux" ];
  };
}
