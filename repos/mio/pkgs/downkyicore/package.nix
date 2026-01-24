{
  lib,
  stdenv,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  icoutils,

  aria2,
  ffmpeg,
  fontconfig,
  freetype,
  icu,
  krb5,
  openssl,
  zlib,
  lttng-ust_2_12,
  xorg,
}:

buildDotnetModule (finalAttrs: {
  pname = "downkyicore";
  version = "1.0.23";

  src = fetchFromGitHub {
    owner = "yaobiao131";
    repo = "downkyicore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1APolFe2eq7aIZdg3Sl4DI/6lnvaAgX/GDcHx3M+o/I=";
  };

  projectFile = "DownKyi/DownKyi.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  executables = [ "DownKyi" ];

  nativeBuildInputs = [
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    icoutils
  ];

  buildInputs = [
    aria2
    ffmpeg
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    fontconfig
    freetype
    icu
    krb5
    openssl
    zlib
    lttng-ust_2_12
    (lib.getLib stdenv.cc.cc)
  ];

  runtimeDeps = lib.optionals stdenv.hostPlatform.isLinux (
    with xorg;
    [
      libX11
      libXcursor
      libXext
      libXi
      libXrandr
      libICE
      libSM
    ]
  );

  postPatch = ''
    substituteInPlace DownKyi/DownKyi.csproj DownKyi.Core/DownKyi.Core.csproj \
      --replace-fail net6.0 net8.0
  '';

  makeWrapperArgs = [
    "--chdir"
    "${placeholder "out"}/lib/downkyicore"
  ];

  passthru.updateScript = ./update.sh;

  # Provide system ffmpeg/aria2 binaries and license texts where the app expects them.
  postInstall = ''
    mkdir -p $out/lib/downkyicore/{aria2,ffmpeg}

    ln -s ${aria2}/bin/aria2c $out/lib/downkyicore/aria2/aria2c
    ln -s ${ffmpeg}/bin/ffmpeg $out/lib/downkyicore/ffmpeg/ffmpeg
    ln -s ${ffmpeg}/bin/ffprobe $out/lib/downkyicore/ffmpeg/ffprobe

    printf 'See https://github.com/aria2/aria2/blob/master/COPYING for aria2 licensing information.\n' > $out/lib/downkyicore/aria2_COPYING.txt
    printf 'See https://ffmpeg.org/legal.html for FFmpeg licensing information.\n' > $out/lib/downkyicore/FFmpeg_LICENSE.txt

  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    cp DownKyi/Resources/favicon.ico downkyicore.ico
    icotool -x downkyicore.ico
    install -Dm444 \
      downkyicore_*_128x128x32.png \
      $out/share/icons/hicolor/128x128/apps/downkyicore.png
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    app="$out/Applications/DownKyi.app"
    mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"

    install -Dm644 ${builtins.toFile "Info.plist" ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleExecutable</key>
        <string>DownKyi</string>
        <key>CFBundleIdentifier</key>
        <string>org.nurpkgs.downkyicore</string>
        <key>CFBundleName</key>
        <string>DownKyi</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>${finalAttrs.version}</string>
        <key>CFBundleVersion</key>
        <string>${finalAttrs.version}</string>
        <key>CFBundleIconFile</key>
        <string>downkyicore.ico</string>
      </dict>
      </plist>
    ''} "$app/Contents/Info.plist"

    install -Dm755 ${builtins.toFile "DownKyi" ''
      #!/bin/sh
      exec "$out/bin/DownKyi" "$@"
    ''} "$app/Contents/MacOS/DownKyi"

    cp DownKyi/Resources/favicon.ico "$app/Contents/Resources/downkyicore.ico"
  '';

  desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
    (makeDesktopItem {
      name = "downkyicore";
      desktopName = "DownKyi";
      comment = "Cross-platform Bilibili downloader";
      exec = "DownKyi";
      icon = "downkyicore";
      categories = [
        "Network"
        "AudioVideo"
      ];
    })
  ];

  meta = {
    description = "Cross-platform Bilibili downloader built with Avalonia";
    homepage = "https://github.com/yaobiao131/downkyicore";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "DownKyi";
  };
})
