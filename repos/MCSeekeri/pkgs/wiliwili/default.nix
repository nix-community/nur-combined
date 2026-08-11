{
  config,
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  ninja,
  wrapGAppsHook4,
  makeWrapper,
  glib,
  gtk4,
  libadwaita,
  pango,
  cairo,
  freetype,
  libxkbcommon,
  libxrandr,
  libXinerama,
  libXi,
  libXcursor,
  libXfixes,
  libX11,
  fontconfig,
  libGL,
  mpv,
  libwebp,
  curl,
  openssl,
  pulseaudio,
  dbus,
  fmt,
  nlohmann_json,
  udev,
  SDL2,
  wayland-scanner,
  copyDesktopItems,
  makeDesktopItem,
  cudaSupport ? config.cudaSupport or false,
  cudaPackages,
  addDriverRunpath,
}:

let
  stdenv' = if cudaSupport then cudaPackages.backendStdenv else stdenv;
in
stdenv'.mkDerivation (finalAttrs: {
  pname = "wiliwili";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "xfangfang";
    repo = "wiliwili";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-J6oUMUzfogsIBj1GpwWmKhjphTV628rG+3w28Dc81Fw=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
    makeWrapper
    wrapGAppsHook4
    copyDesktopItems
    wayland-scanner
  ] ++ lib.optionals cudaSupport [
    addDriverRunpath
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    pango
    cairo
    freetype
    fontconfig
    libGL
    mpv
    libwebp
    curl
    openssl
    pulseaudio
    libX11
    dbus
    fmt
    nlohmann_json
    udev
    SDL2
    libxrandr
    libxkbcommon
    libXinerama
    libXi
    libXcursor
    libXfixes
  ] ++ lib.optionals cudaSupport [
    cudaPackages.cuda_cudart
  ];

  cmakeFlags = [
    "-DPLATFORM_DESKTOP=ON"
    "-DUSE_SYSTEM_CURL=ON"
    "-DUSE_SYSTEM_FMT=ON"
    "-DUSE_SYSTEM_SDL2=ON"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec $out/bin $out/share
    find . -name wiliwili -type f -exec cp {} $out/libexec/wiliwili \;
    cp -r resources $out/share/
    ln -s $out/libexec/wiliwili $out/bin/wiliwili

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/wiliwili \
      --chdir $out/share
  '' + lib.optionalString cudaSupport ''
    addDriverRunpath $out/libexec/wiliwili
    wrapProgram $out/bin/wiliwili \
      --prefix LD_LIBRARY_PATH : ${addDriverRunpath.driverLink}/lib \
      --suffix VK_ADD_DRIVER_FILES : "${addDriverRunpath.driverLink}/share/vulkan/icd.d"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "cn.xfangfang.wiliwili";
      desktopName = "WiliWili";
      comment = "Bilibili video client";
      exec = "wiliwili %u";
      icon = "cn.xfangfang.wiliwili";
      categories = [ "Video" "Network" ];
    })
  ];

  meta = with lib; {
    description = "A cross-platform bilibili client built with wlengine";
    homepage = "https://github.com/xfangfang/wiliwili";
    license = licenses.mit;
    mainProgram = "wiliwili";
    platforms = platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with maintainers; [ MCSeekeri ];
  };
})
