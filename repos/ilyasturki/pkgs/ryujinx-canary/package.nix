{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromForgejo,
  wrapGAppsHook3,
  alsa-lib,
  dbus,
  ffmpeg,
  fontconfig,
  glew,
  gtk3,
  libGL,
  libdecor,
  libdrm,
  libgdiplus,
  libice,
  libsm,
  libsoundio,
  libusb1,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxkbcommon,
  libxrandr,
  mesa,
  openal,
  pipewire,
  pulseaudio,
  sndio,
  udev,
  vulkan-loader,
  wayland,
}:

buildDotnetModule rec {
  pname = "ryujinx-canary";
  version = "1.3.351";

  src = fetchFromForgejo {
    domain = "git.ryujinx.app";
    owner = "projects";
    repo = "Ryubing";
    # Canary and stable share one repo and differ only by tag prefix. nixpkgs'
    # `ryubing` filters `Canary` out by design, so stable has not moved since
    # 1.3.3 (2025-10-11) while canary ships near-daily.
    tag = "Canary-${version}";
    hash = "sha256-zaER6RTggNHMmuH2Z5KjC0Etvwg1ymn77ZpFLFQFoXI=";
  };

  nativeBuildInputs = [ wrapGAppsHook3 ];

  enableParallelBuilding = false;

  # Canary's global.json asks for 10.0.301 with rollForward=latestFeature;
  # nixpkgs' `ryubing` is still on 9 because stable 1.3.3 predates the bump.
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  nugetDeps = ./deps.json;

  # Canary moved from SDL2 to Ryujinx.SDL3-CS, whose NuGet ships a prebuilt
  # runtimes/linux-x64/native/libSDL3.so rather than linking nixpkgs' sdl3.
  # `patchelf --print-needed` on it lists only libc and libm: everything else --
  # the audio backends, the Wayland and X11 stacks, libudev for gamepad hotplug
  # -- is reached through dlopen by soname, so it resolves against this list at
  # runtime through the wrapper's LD_LIBRARY_PATH and nothing else.
  runtimeDeps = [
    alsa-lib
    dbus
    ffmpeg
    fontconfig.lib
    glew
    gtk3
    libGL
    libdecor
    libdrm
    libgdiplus
    libice
    libsm
    libsoundio
    libusb1
    libx11
    libxcursor
    libxext
    libxi
    libxkbcommon
    libxrandr
    mesa
    openal
    pipewire
    pulseaudio
    sndio
    udev
    vulkan-loader
    wayland
  ];

  projectFile = "Ryujinx.sln";
  testProjectFile = "src/Ryujinx.Tests/Ryujinx.Tests.csproj";

  # DISABLE_UPDATER: the in-app updater downloads a release over the store path.
  # FORCE_EXTERNAL_BASE_DIR: without it the emulator writes its data next to the
  # executable, which is read-only here.
  dotnetFlags = [ "/p:ExtraDefineConstants=DISABLE_UPDATER%2CFORCE_EXTERNAL_BASE_DIR" ];

  executables = [ "Ryujinx" ];

  # Avalonia has no Wayland backend, so this runs through XWayland either way;
  # left to autodetect, SDL picks the Wayland driver and the window never appears.
  makeWrapperArgs = [ "--set SDL_VIDEODRIVER x11" ];

  preFixup = ''
    mkdir -p $out/share/{applications,icons/hicolor/256x256/apps,mime/packages}

    pushd ${src}/distribution/linux
    install -Dm644 ./app.ryujinx.Ryujinx.desktop $out/share/applications/app.ryujinx.Ryujinx.desktop
    install -Dm755 ./Ryujinx.sh                  $out/bin/Ryujinx.sh
    install -Dm644 ./mime/Ryujinx.xml            $out/share/mime/packages/Ryujinx.xml
    install -Dm644 ../misc/Logo.png              $out/share/icons/hicolor/256x256/apps/app.ryujinx.Ryujinx.png
    popd

    ln -s $out/bin/Ryujinx $out/bin/ryujinx
  '';

  meta = {
    description = "Ryubing canary builds: Nintendo Switch emulator, community fork of Ryujinx";
    homepage = "https://ryujinx.app";
    changelog = "https://git.ryujinx.app/Ryubing/Canary/releases/tag/${version}";
    license = lib.licenses.mit;
    mainProgram = "Ryujinx";
    platforms = [ "x86_64-linux" ];
  };
}
