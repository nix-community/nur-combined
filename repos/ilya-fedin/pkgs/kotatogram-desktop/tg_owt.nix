{ lib, stdenv, fetchFromGitHub, fetchpatch, pkg-config, cmake, ninja, yasm
, libjpeg, openssl, libopus, ffmpeg, protobuf, openh264, usrsctp, libvpx
, libX11, libXtst, libXcomposite, libXdamage, libXext, libXrender, libXrandr, libXi
, glib, abseil-cpp, pipewire
, Cocoa, AppKit, IOKit, IOSurface, Foundation, AVFoundation, CoreMedia, VideoToolbox
, CoreGraphics, CoreVideo, OpenGL, Metal, MetalKit, CoreFoundation, ApplicationServices
}:

stdenv.mkDerivation {
  pname = "tg_owt";
  version = "unstable-2021-12-12";

  src = fetchFromGitHub {
    owner = "desktop-app";
    repo = "tg_owt";
    rev = "429a6869e4a164e0aad2d8657db341d56f9a6a6f";
    sha256 = "sha256-aBN2V71ffpJ8N223zqmRBVsjcJ9RrB3QnJcNhhXLZ+A=";
    fetchSubmodules = true;
  };

  patches = lib.optionals stdenv.isDarwin [
    # let it build with nixpkgs 10.12 sdk
    ./tg_owt-10.12-sdk.patch
  ];

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ pkg-config cmake ninja yasm ];

  buildInputs = [
    libjpeg openssl libopus ffmpeg protobuf openh264 usrsctp libvpx abseil-cpp
  ] ++ lib.optionals stdenv.isLinux [
    libX11 libXtst libXcomposite libXdamage libXext libXrender libXrandr libXi
    glib pipewire
  ] ++ lib.optionals stdenv.isDarwin [
    Cocoa AppKit IOKit IOSurface Foundation AVFoundation CoreMedia VideoToolbox
    CoreGraphics CoreVideo OpenGL Metal MetalKit CoreFoundation ApplicationServices
  ];

  # https://github.com/NixOS/nixpkgs/issues/130963
  NIX_LDFLAGS = lib.optionalString stdenv.isDarwin "-lc++abi";

  enableParallelBuilding = true;

  cmakeFlags = [
    # Building as a shared library isn't officially supported and may break at any time.
    "-DBUILD_SHARED_LIBS=OFF"
    # tdesktop has its own openal backend, it doesn't use backends from tg_owt
    "-DTG_OWT_BUILD_AUDIO_BACKENDS=OFF"
  ];

  propagatedBuildInputs = [
    # Required for linking downstream binaries.
    abseil-cpp openh264 usrsctp libvpx
  ];

  meta = with lib; {
    license = licenses.bsd3;
    maintainers = with maintainers; [ ilya-fedin ];
  };
}
