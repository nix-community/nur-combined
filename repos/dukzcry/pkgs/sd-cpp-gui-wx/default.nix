{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  openssl, curl, exiv2, pkg-config, gtk3, libsysprof-capture, pcre2, util-linux, libselinux,
  libsepol, libthai, wxGTK32, libdatrie, xorg, libsecret, libpng,
  vulkan-headers, shaderc, glslang, vulkan-loader
}:

# todo: remove with next nixos release
let cpu_features = stdenv.mkDerivation rec {
  pname = "cpu_features";
  version = "0.9.0";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "google";
    repo = "cpu_features";
    rev = "v${version}";
    hash = "sha256-uXN5crzgobNGlLpbpuOxR+9QVtZKrWhxC/UjQEakJwk=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DBUILD_SHARED_LIBS=ON" ];
};
# todo: remove with next nixos release
wxGTK32' = wxGTK32.overrideAttrs (oldAttrs: rec {
  buildInputs = oldAttrs.buildInputs ++ [ libsecret ];
});
socketscpp = fetchFromGitHub {
  owner = "CJLove";
  repo = "sockets-cpp";
  rev = "b6c94e2bc63f090232e93d92c8d29a79f0d715de";
  hash = "sha256-YjgFENvdv8a40kzsbRma1Y3wu9FWsrCkEnDH34c0J6E=";
};
sdcpp = fetchFromGitHub {
  owner = "leejet";
  repo = "stable-diffusion.cpp";
  rev = "master-fbd42b6";
  hash = "sha256-SonGbFIu8ZSWA2rGv4fo/p1uXaA0f/ih/ED66d1Bh/w=";
  fetchSubmodules = true;
};
in stdenv.mkDerivation rec {
  pname = "sd-cpp-gui-wx";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "fszontagh";
    repo = "sd.cpp.gui.wx";
    rev = "v${version}";
    hash = "sha256-NcXCwM8QngG4k8hgyFl+w+J9lu0pBUfzyAfSKbc82i0=";
  };

  nativeBuildInputs = [
    cmake pkg-config
    vulkan-headers shaderc glslang
  ];

  buildInputs = [
    openssl curl exiv2 gtk3 libsysprof-capture pcre2 util-linux libselinux libsepol libthai
    wxGTK32' libdatrie xorg.libXdmcp cpu_features libpng
    vulkan-loader
  ];

  patches = [ ./patch-CMakeLists.txt ];

  preConfigure = ''
    mkdir -p /build/source/build
    cp -r ${sdcpp} /build/source/build/sdcpp
    cp -r ${socketscpp} /build/source/build/socketscpp
    chmod -R +w /build/source/build/sdcpp /build/source/build/socketscpp

    export nixpath="$out/lib/"
    substituteAllInPlace src/ui/MainWindowUI.cpp

    substituteInPlace src/MainApp.h --replace-fail "if (isIntelGPU())" "if (true)"
  '';

  cmakeFlags = [
    "-DSD_VULKAN=ON"
  ];

  meta = {
    description = "Stable Diffusion GUI written in C++";
    homepage = "https://stable-diffusion.fsociety.hu/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "sd-cpp-gui-wx";
    platforms = lib.platforms.all;
  };
}
