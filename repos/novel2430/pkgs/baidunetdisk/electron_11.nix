{
  lib,
  stdenv,
  makeWrapper,
  fetchurl,
  wrapGAppsHook3,
  glib,
  gtk3,
  unzip,
  at-spi2-atk,
  libdrm,
  mesa,
  libxkbcommon,
  libGL,
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
}:
let
  headersFetcher =
    fetchurl {
      url = "https://artifacts.electronjs.org/headers/dist/v11.5.0/node-v11.5.0-headers.tar.gz";
      sha256 = "1zkdgpjrh1dc9j8qyrrrh49v24960yhvwi2c530qbpf2azgqj71b";
    };

  electronLibPath = lib.makeLibraryPath (
    [
      alsa-lib
      at-spi2-atk
      cairo
      cups
      dbus
      expat
      gdk-pixbuf
      glib
      gtk3
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
      stdenv.cc.cc.lib
      systemd
      libdrm
      mesa
      libxkbcommon
    ]
  );
in
stdenv.mkDerivation {
  pname = "electron_11";
  version = "11.4.9";
  src = fetchurl {
    url = "https://github.com/electron/electron/releases/download/v11.4.9/electron-v11.4.9-linux-x64.zip";
    sha256 = "sha256-wY7S4W5gyh7d0Bqy5P/yu/2fGXqxe3V3FV8FaHKX174=";
  };

  passthru.headers = headersFetcher;

  buildInputs = [
    glib
    gtk3
  ];

  nativeBuildInputs = [
    unzip
    makeWrapper
    wrapGAppsHook3
  ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/electron $out/bin
    unzip -d $out/libexec/electron $src
    ln -s $out/libexec/electron/electron $out/bin
    chmod u-x $out/libexec/electron/*.so*

    runHook postInstall
  '';

  postFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${electronLibPath}:$out/libexec/electron" \
      $out/libexec/electron/.electron-wrapped

    # patch libANGLE
    patchelf \
      --set-rpath "${
        lib.makeLibraryPath [
          libGL
          pciutils
        ]
      }" \
      $out/libexec/electron/lib*GL*
  '';

  meta = {
    description = "Cross platform desktop application shell";
    homepage = "https://github.com/electron/electron";
    license = lib.licenses.mit;
    mainProgram = "electron";
    platforms = [
      "x86_64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
