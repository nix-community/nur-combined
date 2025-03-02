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
  version = "unstable-2024-11-26";

  src = fetchFromGitHub {
    owner = "abstract-creations";
    repo = pname;
    rev = "5368c8d6896f1a86327517df1cbff814d2235c77";
    hash = "sha256-NLYDPKlqitWiPFqfLt8PPK25GJ5irKZk65qK26Nv9Ys=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-90KLBv+RWlFwIF1Bm1QMr59CsVd10fBSnni9n2symwA=";

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

  meta = with lib; {
    mainProgram = "subwoofer";
    description = "feel your content ";
    homepage = "https://github.com/abstract-creations/subwoofer";
    license = licenses.mit;
    maintainers = with maintainers; [_999eagle];
  };
}
