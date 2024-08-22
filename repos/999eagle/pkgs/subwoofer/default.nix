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
  version = "unstable-2023-12-03";

  src = fetchFromGitHub {
    owner = "dynamicbark";
    repo = pname;
    rev = "b6eca52ca872a7ce8cfe5ceb97651e36134a9df8";
    hash = "sha256-19SL+kBcnA2wr0t+5RmGSdPxpHMDl48fSl1trFQZ3ss=";
  };
  cargoHash = "sha256-GO165gMzsLEazG5y4PipW0pyBXNeveHXqaKIkbqbtA8=";

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
