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
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    aria2
    ffmpeg
    fontconfig
    freetype
    icu
    krb5
    openssl
    zlib
    lttng-ust_2_12
    (lib.getLib stdenv.cc.cc)
  ];

  runtimeDeps = with xorg; [
    libX11
    libXcursor
    libXext
    libXi
    libXrandr
    libICE
    libSM
  ];

  postPatch = ''
    substituteInPlace DownKyi/DownKyi.csproj DownKyi.Core/DownKyi.Core.csproj \
      --replace net6.0 net8.0
  '';

  makeWrapperArgs = [
    "--chdir"
    "$out/lib/downkyicore"
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

    install -Dm644 DownKyi/Resources/favicon.ico $out/share/icons/hicolor/256x256/apps/downkyicore.ico
  '';

  desktopItems = [
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
    platforms = [ "x86_64-linux" ];
    mainProgram = "DownKyi";
  };
})
