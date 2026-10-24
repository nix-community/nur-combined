{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  gettext,
  cutefish-toolkit,
  icu,
  mpv,
}:

let
  cu = import ../cutefish/mk.nix { inherit lib; };
in
stdenv.mkDerivation {
  pname = "cutefish-video-player";
  version = cu.version "2026-10-20";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "video-player";
    rev = "86f2eab74dadfd0482f457122547e0684bca3f23";
    hash = "sha256-3mPfyqau/0JExgwKToZ6qHJgDlXLNb2BushKxgzVfO0=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    icu
    mpv
  ];

  cmakeFlags = cu.cmakeFlags;

  # libmpv is dlopened by SONAME the first time a file is played.
  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath [ mpv ]} "$out/bin/cutefish-video-player"
  '';

  meta = {
    inherit (cu) homepage platforms;
    description = "Video player for the Cutefish desktop, using libmpv";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-video-player";
  };
}
