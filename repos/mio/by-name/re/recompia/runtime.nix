{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  unzip,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  python3,
  libXtst,
  libXfixes,
  libgbm,
  dbus,
  udev,
  fribidi,
  libthai,
  wayland-scanner,
  libX11,
  libXext,
  libXrandr,
  libXcursor,
  libXi,
  libXScrnSaver,
  libxcb,
  wayland,
  wayland-protocols,
  libxkbcommon,
  alsa-lib,
  libpulseaudio,
  libdrm,
  libGL,
  vulkan-loader,
  src,
  version,
}:
let
  deps = lib.mapAttrs (
    name: spec:
    stdenvNoCC.mkDerivation {
      name = "recompia-${name}-source";
      src = fetchurl spec;
      nativeBuildInputs = [ unzip ];
      dontConfigure = true;
      dontBuild = true;
      installPhase = "cp -r . $out";
    }
  ) (builtins.fromJSON (builtins.readFile ./runtime-deps.json));
  astc = fetchFromGitHub {
    owner = "ARM-software";
    repo = "astc-encoder";
    rev = "5.7.0";
    hash = "sha256-g/XuCBs07G8Tpod6be8lQ5A8Jh52JUzrstrToAgT2ag=";
  };
in
stdenv.mkDerivation {
  pname = "recompia-runtime";
  inherit src version;
  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    wayland-scanner
    python3
  ];
  buildInputs = [
    libXtst
    libXfixes
    libgbm
    dbus
    udev
    fribidi
    libthai
    libX11
    libXext
    libXrandr
    libXcursor
    libXi
    libXScrnSaver
    libxcb
    wayland
    wayland-protocols
    libxkbcommon
    alsa-lib
    libpulseaudio
    libdrm
    libGL
  ];
  postPatch = ''
    mkdir -p tools/textures/third_party
    cp -r ${astc} tools/textures/third_party/astc-encoder
  '';
  preConfigure = "cd game-build";
  cmakeFlags = [
    "-DPKP_RT_DLL=ON"
    "-DPKP_RELEASE=ON"
    "-DPKP_VERSION=${version}"
    "-DSDL_WAYLAND=ON"
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
  ]
  ++ lib.mapAttrsToList (name: path: "-DFETCHCONTENT_SOURCE_DIR_${lib.toUpper name}=${path}") deps;
  ninjaFlags = [ "pkp_rt" ];
  installPhase = ''
    install -Dm755 libpkp_rt.so $out/lib/libpkp_rt.so
    patchelf --add-rpath ${lib.makeLibraryPath [ vulkan-loader ]} $out/lib/libpkp_rt.so
  '';
}
