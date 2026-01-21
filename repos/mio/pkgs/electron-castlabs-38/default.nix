{
  lib,
  stdenv,
  makeBinaryWrapper,
  fetchurl,
  fetchzip,
  wrapGAppsHook3,
  glib,
  gtk3,
  gtk4,
  unzip,
  at-spi2-atk,
  libdrm,
  libgbm,
  libxkbcommon,
  libxshmfence,
  libGL,
  vulkan-loader,
  alsa-lib,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  nss,
  nspr,
  xorg,
  pango,
  systemd,
  pciutils,
  libnotify,
  pipewire,
  libsecret,
  libpulseaudio,
  speechd-minimal,
}:

let
  version = "38.7.2+wvcus";
  tag = "linux-x64";
  src = fetchurl {
    url = "https://github.com/castlabs/electron-releases/releases/download/v${version}/electron-v${version}-${tag}.zip";
    sha256 = "sha256-MDCCywxvoCnv6aSYK7rUAoAU2W2URH16UjRc5hGq9yI=";
  };
  headers = fetchzip {
    name = "electron-${version}-headers";
    url = "https://artifacts.electronjs.org/headers/dist/v38.7.2/node-v38.7.2-headers.tar.gz";
    sha256 = "sha256-iZMj4lmnqbL7zrdGBqy23VIsXifyzrlIN2EM5VLti18=";
    stripRoot = false;
  };

  electronLibPath = lib.makeLibraryPath [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    gtk4
    nss
    nspr
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxkbfile
    pango
    pciutils
    stdenv.cc.cc
    systemd
    libnotify
    pipewire
    libsecret
    libpulseaudio
    speechd-minimal
    libdrm
    libgbm
    libxkbcommon
    libxshmfence
    libGL
    vulkan-loader
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "electron-castlabs";
  inherit version src;

  meta = {
    description = "Electron (castlabs fork)";
    homepage = "https://github.com/castlabs/electron-releases";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "electron";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };

  buildInputs = [
    glib
    gtk3
    gtk4
  ];

  nativeBuildInputs = [
    unzip
    makeBinaryWrapper
    wrapGAppsHook3
  ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/libexec/electron
    unzip -d $out/libexec/electron $src
    chmod u-x $out/libexec/electron/*.so*
  '';

  # We don't want to wrap the contents of $out/libexec automatically
  dontWrapGApps = true;

  preFixup = ''
    makeWrapper "$out/libexec/electron/electron" $out/bin/electron \
      "''${gappsWrapperArgs[@]}"
  '';

  postFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${electronLibPath}:$out/libexec/electron" \
      $out/libexec/electron/electron \
      $out/libexec/electron/chrome_crashpad_handler

    # patch libANGLE
    patchelf \
      --set-rpath "${
        lib.makeLibraryPath [
          libGL
          pciutils
          vulkan-loader
        ]
      }" \
      $out/libexec/electron/lib*GL*

    # replace bundled vulkan-loader
    rm "$out/libexec/electron/libvulkan.so.1"
    ln -s -t "$out/libexec/electron" "${lib.getLib vulkan-loader}/lib/libvulkan.so.1"
  '';

  passthru = {
    dist = finalAttrs.finalPackage + "/libexec/electron";
    inherit headers;
  };
})
