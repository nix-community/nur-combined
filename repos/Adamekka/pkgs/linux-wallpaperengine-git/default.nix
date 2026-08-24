{ SDL2
, SDL2_mixer
, autoPatchelfHook
, cef-binary
, cmake
, common-updater-scripts
, coreutils
, dbus
, egl-wayland
, fetchFromGitHub
, ffmpeg
, fftw
, file
, freetype
, git
, glew
, glfw
, glm
, gmp
, kissfftFloat
, lib
, libdecor
, libffi
, libglut
, libpng
, libpulseaudio
, libxau
, libxdmcp
, libxpm
, libxrandr
, libxxf86vm
, lz4
, maintainer
, mpv
, pkg-config
, pulseaudio
, python3
, stdenv
, wayland
, wayland-protocols
, wayland-scanner
, writeShellApplication
, zlib
,
}:

let
  # CEF's API and binary layout must match the version selected by upstream CMake.
  cef = cef-binary.override {
    chromiumVersion = "135.0.7049.52";
    gitRevision = "cbc1c5b";
    srcHashes = {
      aarch64-linux = "sha256-LK5JvtcmuwCavK7LnWmMF2UDpM5iIZOmsuZS/t9koDs=";
      x86_64-linux = "sha256-JKwZgOYr57GuosM31r1Lx3DczYs35HxtuUs5fxPsTcY=";
    };
    version = "135.0.17";
  };
  currentRev = "b016d7d1fdcf4e5fd2f9c9fa420a8aaa07fee02d";
in
stdenv.mkDerivation {
  pname = "linux-wallpaperengine-git";
  version = "0.0.1-unstable-2026-06-09";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    hash = "sha256-ExWAYdSFW5plPuS3/jxTPMXIly6zVb5GojE3e37imZM=";
    owner = "Almamu";
    repo = "linux-wallpaperengine";
    rev = currentRev;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    cmake
    file
    pkg-config
    python3
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
    dbus
    egl-wayland
    ffmpeg
    fftw
    freetype
    glew
    glfw
    glm
    gmp
    kissfftFloat
    libdecor
    libffi
    libglut
    libpng
    libpulseaudio
    libxau
    libxdmcp
    libxpm
    libxrandr
    libxxf86vm
    lz4
    mpv
    pulseaudio
    wayland
    wayland-protocols
    wayland-scanner
    zlib
  ];

  cmakeFlags = [
    "-DCEF_ROOT=${cef}"
    "-DCMAKE_INSTALL_PREFIX=${builtins.placeholder "out"}/share/linux-wallpaperengine"
  ];

  postPatch = ''
    # Fail source updates until the matching CEF archive and hashes are pinned above.
    grep -F 'set(CEF_VERSION "135.0.17+gcbc1c5b+chromium-135.0.7049.52")' CMakeLists.txt > /dev/null
  '';

  postConfigure = ''
    # Hyprland needs the native Wayland driver, not GLFW's XWayland fallback.
    grep -F -- '-DENABLE_WAYLAND' compile_commands.json > /dev/null
  '';

  postInstall = ''
    # Keep the executable beside its CEF resources and omit vendored headers and libraries.
    rm -rf $out/bin $out/include $out/lib
    chmod 755 $out/share/linux-wallpaperengine/linux-wallpaperengine
    mkdir $out/bin
    ln -s $out/share/linux-wallpaperengine/linux-wallpaperengine $out/bin/linux-wallpaperengine
  '';

  preFixup = ''
    find $out/share/linux-wallpaperengine -type f -exec file {} \; | grep 'ELF' | cut -d: -f1 | while read -r elf_file; do
      patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" "$elf_file"
    done
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    test -x $out/bin/linux-wallpaperengine
    test -f $out/share/linux-wallpaperengine/icudtl.dat
    test -f $out/share/linux-wallpaperengine/libcef.so
    test -d $out/share/linux-wallpaperengine/locales

    runHook postInstallCheck
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "update-linux-wallpaperengine-git";
    runtimeInputs = [
      common-updater-scripts
      coreutils
      git
    ];
    text = ''
      repository="https://github.com/Almamu/linux-wallpaperengine.git"
      temporary_directory="$(mktemp -d)"
      trap 'rm -rf "$temporary_directory"' EXIT

      git clone --branch main --depth 1 "$repository" "$temporary_directory"
      latest_revision="$(git -C "$temporary_directory" rev-parse HEAD)"

      if [[ "$latest_revision" == "${currentRev}" ]]; then
        echo "linux-wallpaperengine-git is up to date"
        exit 0
      fi

      commit_date="$(git -C "$temporary_directory" show -s --format=%cs HEAD)"
      # Upstream's release tag is not in main's history, so preserve the last release manually.
      update-source-version \
        linux-wallpaperengine-git \
        "0.0.1-unstable-$commit_date" \
        --ignore-same-version \
        --rev="$latest_revision" \
        --print-changes
    '';
  });

  meta = {
    description = "Wallpaper Engine backgrounds for Linux";
    homepage = "https://github.com/Almamu/linux-wallpaperengine";
    hydraPlatforms = [ "x86_64-linux" ];
    license = lib.licenses.gpl3Plus;
    mainProgram = "linux-wallpaperengine";
    maintainers = [ maintainer ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
