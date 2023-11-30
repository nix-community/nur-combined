{
  lib,
  rustPlatform,
  fetchFromGitHub,
  patchelf,
  pkg-config,
  dbus,
  fontconfig,
  alsa-lib,
  udev,
  openssl,
  xorg,
}:
rustPlatform.buildRustPackage rec {
  pname = "subwoofer";
  version = "unstable-2023-11-28";

  src = fetchFromGitHub {
    owner = "smol-skyz";
    repo = pname;
    rev = "bc55fea000f73aee166b85f34273871afbd152c4";
    hash = "sha256-XZaxgfh1bH1d1V35x0nQYfl/KPQ+A4aBDhV/vV9RMAs=";
  };
  cargoHash = "sha256-16esFE1e5mr41G74G22BG3t6CT46g2t6B/9EGty08xI=";

  nativeBuildInputs = [
    pkg-config
    patchelf
  ];

  buildInputs = [
    dbus
    fontconfig
    alsa-lib
    udev
    openssl
  ];

  fixupPhase = ''
    runHook preFixup

    patchelf \
      --add-rpath ${lib.makeLibraryPath [xorg.libX11 xorg.libXcursor]} \
      $out/bin/subwoofer

    runHook postFixup
  '';
}
