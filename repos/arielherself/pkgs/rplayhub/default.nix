{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, makeWrapper
, nasm
, pkg-config
, SDL2
, libX11
, libXext
, libGL
, zlib
, openssl
, libplist
, libimobiledevice
, nlohmann_json
, curl
, coreutils
, python3
}:

let
  # The pins below are the ones upstream's scripts/ fetch into deps/.

  # scripts/build-ffmpeg-rvra.sh: patched with patches/ffmpeg-rvra.patch and
  # linked statically. nixpkgs' FFmpeg cannot stand in, as the stock decoder
  # garbles the phone's stream from the first resolution downshift.
  ffmpegSrc = fetchurl {
    url = "https://ffmpeg.org/releases/ffmpeg-8.1.2.tar.xz";
    hash = "sha256-RkvrXnvwwxHmi0WuLwTpzCr4iFGrtAgiMXQqdNl7Ukw=";
  };

  # scripts/fetch-gui-deps.sh. Compiled into the GUI from source; nixpkgs'
  # imgui is an older release.
  imgui = fetchFromGitHub {
    owner = "ocornut";
    repo = "imgui";
    rev = "v1.91.8";
    hash = "sha256-+BuSAXvLvOYOmENzxd1pGDE6llWhTGVu7C3RnoVLVzg=";
  };

  # doc/LINUX.md. host-c/Makefile compiles the engine's userspace TCP/IP
  # stack straight from this tree.
  lwip = fetchFromGitHub {
    owner = "lwip-tcpip";
    repo = "lwip";
    rev = "STABLE-2_2_1_RELEASE";
    hash = "sha256-8TYbUgHNv9SV3l203WVfbwDEHFonDAQqdykiX9OoM34=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rplayhub";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "rPlayAI";
    repo = "rPlayHub";
    rev = "linux-v${finalAttrs.version}";
    hash = "sha256-xQ+TguD/NcxYzowJviJqcYTXm6KiAqdVimSqeRUoI1I=";
  };

  patches = [
    # From upstream main (21968b4): with RPLAY_USERSPACE_NET=1 the mounter's
    # socket is lwIP's, but send_plist used the kernel's send(), so RSDCheckin
    # never went out and the DDI never mounted, leaving no screen to capture.
    ./ddi-write-over-tunnel.patch
    # Under motion the encoder drops to 1088x1920 or 720x1280, squeezing the
    # whole screen into that rect anamorphically; the GUI took the rect's own
    # aspect and stretched the picture sideways. Present at the device's
    # screen aspect instead, as upstream main (21968b4) does for the mirror.
    ./gui-present-at-screen-aspect.patch
  ];

  nativeBuildInputs = [
    makeWrapper
    nasm
    pkg-config
  ];

  # nixpkgs carries the exact libimobiledevice stack scripts/build-imd-stack.sh
  # pins (libplist 2.7.0, libimobiledevice 1.4.0), so the engine links it
  # shared instead of building its own.
  buildInputs = [
    SDL2
    libX11
    libXext
    libGL
    zlib
    openssl
    libplist
    libimobiledevice
    nlohmann_json
  ];

  postPatch = ''
    # The GUI looks for its fonts beside the executable, then in the .deb's
    # location.
    substituteInPlace client-c/rplay-gui.cpp \
      --replace-fail /usr/share/rplayhub/fonts $out/share/rplayhub/fonts

    mkdir deps
    ln -s ${imgui} deps/imgui
    ln -s ${lwip} deps/lwip

    mkdir deps/ffmpeg
    tar xf ${ffmpegSrc} -C deps/ffmpeg --strip-components=1
    patch -d deps/ffmpeg -p1 < patches/ffmpeg-rvra.patch
    patchShebangs deps/ffmpeg/configure deps/ffmpeg/ffbuild
  '';

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    (
      cd deps/ffmpeg
      ./configure --disable-doc --disable-autodetect --disable-network --enable-zlib \
        --disable-ffplay --disable-ffprobe --disable-programs
      make -j$NIX_BUILD_CORES
    )

    # IMD_PREFIX=/usr only keeps the Makefile from baking an rpath; headers and
    # libraries come from buildInputs.
    make -C host-c -j$NIX_BUILD_CORES IMD_PREFIX=/usr OPENSSL=/usr
    make -C client-c -j$NIX_BUILD_CORES rplay-gui

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 client-c/rplay-gui $out/bin/rplayhub
    install -Dm755 host-c/cdhost $out/libexec/rplayhub/cdhost
    install -Dm644 -t $out/share/rplayhub/fonts client-c/fonts/*.ttf

    # Like the .deb's rplayhub-engine: unprivileged, over lwIP, no TUN device.
    makeWrapper $out/libexec/rplayhub/cdhost $out/bin/rplayhub-engine \
      --set-default RPLAY_USERSPACE_NET 1

    install -Dm755 scripts/fetch-ddi.sh $out/bin/rplayhub-fetch-ddi
    wrapProgram $out/bin/rplayhub-fetch-ddi \
      --prefix PATH : ${lib.makeBinPath [ coreutils curl python3 ]}

    install -Dm644 client-c/packaging/rplayhub.desktop -t $out/share/applications
    for size in 128 256; do
      install -Dm644 app/rPlayHub/Assets.xcassets/AppIcon.appiconset/icon_''${size}x$size.png \
        $out/share/icons/hicolor/''${size}x$size/apps/rplayhub.png
    done

    runHook postInstall
  '';

  meta = {
    description = "iPhone screen mirroring and control over USB, a Device Hub for Linux";
    longDescription = ''
      Mirrors an iPhone (iOS 27 or later, Developer Mode on) over USB with the
      CoreDevice protocol. `rplayhub` is the GUI, `rplayhub-engine` talks to the
      phone, and `rplayhub-fetch-ddi` downloads Apple's Developer Disk Image
      once. The engine needs a running usbmuxd (`services.usbmuxd.enable` on
      NixOS).
    '';
    homepage = "https://github.com/rPlayAI/rPlayHub";
    changelog = "https://github.com/rPlayAI/rPlayHub/releases/tag/linux-v${finalAttrs.version}";
    license = with lib.licenses; [
      gpl3Plus
      lgpl21Plus # FFmpeg, linked in statically
      ofl # Inter fonts
    ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [
      {
        name = "arielherself";
        github = "arielherself";
        githubId = 107245128;
      }
    ];
    mainProgram = "rplayhub";
    platforms = lib.platforms.linux;
  };
})
