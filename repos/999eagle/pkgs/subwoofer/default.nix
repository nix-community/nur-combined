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
  version = "unstable-2024-08-23";

  src = fetchFromGitHub {
    owner = "999eagle";
    repo = pname;
    rev = "c927f61f6457ef9e29928e45e5af992d5f84d00d";
    hash = "sha256-OgbnblC0308JGeHL8GbL0CdUEqn3qPbenzGEA5FZaAg=";
  };
  cargoHash = "sha256-I0sxR7B/ovdCf7hiAXmL+hCZ6ZNxI1gTvE/Z+x+CYRw=";

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
