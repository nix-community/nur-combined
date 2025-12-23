{
  lib,
  stdenv,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,

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
    rev = "v${finalAttrs.version}";
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
  ++ lib.optionals stdenv.isLinux [
    autoPatchelfHook
  ];

  buildInputs = [
    aria2
    ffmpeg
  ]
  ++ lib.optionals stdenv.isLinux [
    fontconfig
    freetype
    icu
    krb5
    openssl
    zlib
    lttng-ust_2_12
    (lib.getLib stdenv.cc.cc)
  ];

  runtimeDeps = lib.optionals stdenv.isLinux (
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
    "${builtins.placeholder "out"}/lib/downkyicore"
  ];

  passthru.updateScript = ./update.sh;

  # Provide system ffmpeg/aria2 binaries and license texts where the app expects them.
  postInstall = ''
    mkdir -p $out/lib/downkyicore/{aria2,ffmpeg}

    ln -s ${aria2}/bin/aria2c $out/lib/downkyicore/aria2/aria2c
    ln -s ${ffmpeg}/bin/ffmpeg $out/lib/downkyicore/ffmpeg/ffmpeg
    ln -s ${ffmpeg}/bin/ffprobe $out/lib/downkyicore/ffmpeg/ffprobe

    if [ -f ${aria2}/share/doc/aria2/COPYING ]; then
      install -Dm644 ${aria2}/share/doc/aria2/COPYING $out/lib/downkyicore/aria2_COPYING.txt
    fi

    if [ -f ${ffmpeg}/share/doc/ffmpeg/COPYING.GPLv3 ]; then
      install -Dm644 ${ffmpeg}/share/doc/ffmpeg/COPYING.GPLv3 $out/lib/downkyicore/FFmpeg_LICENSE.txt
    elif [ -f ${ffmpeg}/share/licenses/ffmpeg/COPYING.GPLv3 ]; then
      install -Dm644 ${ffmpeg}/share/licenses/ffmpeg/COPYING.GPLv3 $out/lib/downkyicore/FFmpeg_LICENSE.txt
    else
      printf 'See https://ffmpeg.org/legal.html for FFmpeg licensing information.\n' > $out/lib/downkyicore/FFmpeg_LICENSE.txt
    fi

  ''
  + lib.optionalString stdenv.isLinux ''
    install -Dm644 DownKyi/Resources/favicon.ico $out/share/icons/hicolor/256x256/apps/downkyicore.ico
  ''
  + lib.optionalString stdenv.isDarwin ''
    app="$out/Applications/DownKyi.app"
    mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"

    cat > "$app/Contents/Info.plist" <<'EOF'
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
    EOF

    cat > "$app/Contents/MacOS/DownKyi" <<'EOF'
    #!/bin/sh
    exec "$out/bin/DownKyi" "$@"
    EOF
    chmod +x "$app/Contents/MacOS/DownKyi"

    if [ -f DownKyi/Resources/favicon.ico ]; then
      cp DownKyi/Resources/favicon.ico "$app/Contents/Resources/downkyicore.ico"
    fi
  '';

  desktopItems = lib.optionals stdenv.isLinux [
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
