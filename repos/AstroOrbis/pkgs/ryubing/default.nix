{
  lib,
  buildDotnetModule,
  cctools,
  darwin,
  dotnetCorePackages,
  fetchFromGitea,
  libX11,
  libgdiplus,
  moltenvk,
  ffmpeg,
  fontconfig,
  openal,
  libsoundio,
  sndio,
  stdenv,
  pulseaudio,
  vulkan-loader,
  glew,
  libGL,
  libICE,
  libSM,
  libXcursor,
  libXext,
  libXi,
  libXrandr,
  udev,
}:

buildDotnetModule rec {
  pname = "ryubing";
  version = "1.3.333";

  src = fetchFromGitea {
    domain = "git.ryujinx.app";
    owner = "projects";
    repo = "Ryubing";
    tag = "Canary-${version}";
    hash = "sha256-SlYai8WrtApmHfpOUmdpGzu26YjZr4KYIZgJGu3b50I=";
  };

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isDarwin [
    cctools
    darwin.sigtool
  ];

  enableParallelBuilding = false;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  nugetDeps = ./deps.json;

  runtimeDeps = [
    libX11
    libgdiplus
    openal
    libsoundio
    sndio
    vulkan-loader
    ffmpeg

    # Avalonia UI
    fontconfig
    glew
    libICE
    libSM
    libXcursor
    libXext
    libXi
    libXrandr

    # Headless executable
    libGL
  ]
  ++ lib.optional (!stdenv.hostPlatform.isDarwin) [
    udev
    pulseaudio
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin [ moltenvk ];

  projectFile = "Ryujinx.sln";
  testProjectFile = "src/Ryujinx.Tests/Ryujinx.Tests.csproj";

  # Tests on Darwin currently fail because of Ryujinx.Tests.Unicorn
  doCheck = !stdenv.hostPlatform.isDarwin;

  dotnetFlags = [
    "/p:ExtraDefineConstants=DISABLE_UPDATER%2CFORCE_EXTERNAL_BASE_DIR"
  ];

  executables = [
    "Ryujinx"
  ];

  makeWrapperArgs = [
    # Without this Ryujinx fails to start on wayland. See https://github.com/Ryujinx/Ryujinx/issues/2714
    "--set SDL_VIDEODRIVER x11"
  ];

  preInstall = lib.optionalString stdenv.isLinux ''
    # workaround for https://github.com/Ryujinx/Ryujinx/issues/2349
    mkdir -p $out/lib/sndio-6
    ln -s ${sndio}/lib/libsndio.so $out/lib/sndio-6/libsndio.so.6
  '';

  preFixup = ''
    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      # Restore pulls in both SkiaSharp.NativeAssets.Linux and its .NoDependencies
      # variant, and the latter wins the copy into runtimes/. That build has no
      # fontconfig and only searches /usr/share/fonts, so Avalonia enumerates zero
      # font families and aborts on startup. Swap in the fontconfig-linked build.
      skiaRuntimes=
      for root in "$NUGET_FALLBACK_PACKAGES" "$NUGET_PACKAGES"; do
        [ -n "$root" ] || continue
        for candidate in "$root"/skiasharp.nativeassets.linux/*/runtimes; do
          if [ -d "$candidate" ]; then
            skiaRuntimes=$candidate
            break 2
          fi
        done
      done
      if [ -z "$skiaRuntimes" ]; then
        echo "error: no fontconfig-linked libSkiaSharp.so among the restored packages" >&2
        exit 1
      fi

      skiaReplaced=0
      for native in $out/lib/ryubing/runtimes/*/native/libSkiaSharp.so; do
        rid=$(basename "$(dirname "$(dirname "$native")")")
        if [ -f "$skiaRuntimes/$rid/native/libSkiaSharp.so" ]; then
          install -m644 "$skiaRuntimes/$rid/native/libSkiaSharp.so" "$native"
          skiaReplaced=$((skiaReplaced + 1))
        fi
      done
      if [ "$skiaReplaced" -eq 0 ]; then
        echo "error: found no libSkiaSharp.so to replace" >&2
        exit 1
      fi

      mkdir -p $out/share/{applications,icons/hicolor/256x256/apps,mime/packages}

      pushd ${src}/distribution/linux

      install -D ./app.ryujinx.Ryujinx.desktop $out/share/applications/app.ryujinx.Ryujinx.desktop
      install -D ./Ryujinx.sh                  $out/bin/Ryujinx.sh
      install -D ./mime/Ryujinx.xml            $out/share/mime/packages/Ryujinx.xml
      install -D ../misc/Logo.png              $out/share/icons/hicolor/256x256/apps/app.ryujinx.Ryujinx.png

      popd
    ''}

    # Don't make a softlink on OSX because of its case insensitivity
    ${lib.optionalString (!stdenv.hostPlatform.isDarwin) "ln -s $out/bin/Ryujinx $out/bin/ryujinx"}
  '';

  meta = with lib; {
    homepage = "https://ryujinx.app";
    changelog = "https://git.ryujinx.app/projects/Ryubing/wiki/Changelog";
    description = "Experimental Nintendo Switch Emulator written in C# (community fork of Ryujinx)";
    longDescription = ''
      Ryujinx is an open-source Nintendo Switch emulator, created by gdkchan,
      written in C#. This emulator aims at providing excellent accuracy and
      performance, a user-friendly interface and consistent builds. It was
      written from scratch and development on the project began in September
      2017. The project has since been abandoned on October 1st 2024 and QoL
      updates are now managed under a fork.
    '';
    license = licenses.mit;
    maintainers = with maintainers; [
      jk
      artemist
      willow
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "Ryujinx";
  };
}
