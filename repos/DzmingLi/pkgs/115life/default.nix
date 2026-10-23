{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  desktop-file-utils,
  dotnetCorePackages,
  python3,
  sqlite,
  alsa-lib,
  fontconfig,
  glib,
  glib-networking,
  gtk3,
  libglvnd,
  libice,
  libsm,
  libx11,
  libxcursor,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libnotify,
  libpulseaudio,
  libsecret,
  libsoup_3,
  libva,
  openssl,
  webkitgtk_4_1,
  xdg-utils,
  zlib,
  writeShellApplication,
  nushell,
  nix,
}:

let
  dotnetRuntime = dotnetCorePackages.runtime_10_0;
  # Avalonia, WebKitGTK and .NET load these libraries dynamically.
  runtimeLibraries = [
    alsa-lib
    fontconfig
    glib
    gtk3
    libglvnd
    libice
    libsm
    libx11
    libxcursor
    libxext
    libxfixes
    libxi
    libxrandr
    libnotify
    libpulseaudio
    libsecret
    libsoup_3
    openssl
    webkitgtk_4_1
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "115life";
  version = "37.3.1";

  src = fetchurl {
    url = "https://down.115.com/client/115pc/lin/115Life_${finalAttrs.version}.deb";
    hash = "sha256-44E+Kvg8/+7X4xYFga7/6wfSyzPqjzA/tWi7VwgskxU=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
    desktop-file-utils
    python3
  ];
  buildInputs = runtimeLibraries ++ [
    glib-networking
    stdenv.cc.cc.lib
    libva
    zlib
  ];

  strictDeps = true;
  dontBuild = true;
  dontWrapGApps = true;
  # Stripping the precompiled .NET assemblies corrupts their ReadyToRun data.
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin $out/share
    cp -r opt/115life $out/lib/115life
    python3 ${./unbundle.py} $out/lib/115life
    ln -s ${lib.getLib sqlite}/lib/libsqlite3.so $out/lib/115life/libe_sqlite3.so
    cp -r usr/share/{applications,icons,doc} $out/share/
    substituteInPlace $out/share/applications/life115.desktop \
      --replace-fail 'Exec="/opt/115life/Life115"' "Exec=$out/bin/115life" \
      --replace-fail 'x-scheme-handler/life115;' \
        'x-scheme-handler/life115;x-scheme-handler/magnet;x-scheme-handler/ed2k;x-scheme-handler/thunder;'

    runHook postInstall
  '';

  # The embedded WebKitGTK view needs an X11 window to join Avalonia's window.
  # Override desktop-wide Wayland settings, which prevent the view from initializing.
  preFixup = ''
    makeWrapper ${lib.getExe dotnetRuntime} $out/bin/115life \
      --add-flags "$out/lib/115life/Life115.dll" \
      "''${gappsWrapperArgs[@]}" \
      --set DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 0 \
      --set GDK_BACKEND x11 \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}:$out/lib/115life" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}"
    # The app registers desktop entries and upload actions using this path.
    ln -s $out/bin/115life $out/lib/115life/Life115
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    desktop-file-validate $out/share/applications/life115.desktop
    test -x $out/bin/115life
    test -f $out/share/icons/hicolor/256x256/apps/life115.png
    test ! -e $out/lib/115life/libcoreclr.so
    test ! -e $out/lib/115life/System.Private.CoreLib.dll
    test -L $out/lib/115life/libe_sqlite3.so
    test -x $out/lib/115life/Life115
    runHook postInstallCheck
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "update-115life";
    runtimeInputs = [
      nushell
      nix
      dpkg
    ];
    text = ''exec nu ${./update.nu} "$@"'';
  });

  meta = {
    description = "115 Life cloud storage desktop client";
    homepage = "https://115.com/";
    downloadPage = "https://q.115.com/115/T984564.html";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "115life";
  };
})
