{ lib
, copyDesktopItems
, fetchFromGitHub
, gnome
, installShellFiles
, makeWrapper
, networkmanager
, qrencode
, stdenvNoCC
, xdg-utils
, zbar
}:
stdenvNoCC.mkDerivation rec {
  pname = "wifi-qr";
  version = "unstable-2023-04-19";

  outputs = [ "out" "man" ];

  src = fetchFromGitHub {
    owner = "kokoye2007";
    repo = "wifi-qr";
    rev = "b81d4a44257252f07e745464879aa5618ae3d434";
    hash = "sha256-oGTAr+raJGpK4PV4GdBxX8fIUE8gcbXw7W0SvQJAee0=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  dontBuild = true;

  dontConfigure = true;

  postPatch = ''
    substituteInPlace wifi-qr.desktop \
      --replace "Exec=sh -c 'wifi-qr g'" "Exec=$out/bin/wifi-qr g" \
      --replace "Exec=sh -c 'wifi-qr q'" "Exec=$out/bin/wifi-qr q" \
      --replace "Exec=sh -c 'wifi-qr p'" "Exec=$out/bin/wifi-qr p" \
      --replace "Exec=sh -c 'wifi-qr c'" "Exec=$out/bin/wifi-qr c" \
      --replace "Icon=wifi-qr.svg" "Icon=$out/share/applications/wifi-qr.svg"
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 wifi-qr $out/bin/wifi-qr

    install -Dm644 wifi-qr.desktop $out/share/applications/wifi-qr.desktop
    install -Dm644 wifi-qr.svg $out/share/applications/wifi-qr.svg

    installManPage wifi-qr.1

    runHook postInstall
  '';

  wrapperPath = lib.makeBinPath [
    gnome.zenity
    networkmanager
    qrencode
    xdg-utils
    zbar
  ];

  fixupPhase = ''
    runHook preFixup

    patchShebangs $out/bin/wifi-qr
    wrapProgram $out/bin/wifi-qr --suffix PATH : "${wrapperPath}"

    runHook postFixup
  '';

  meta = with lib; {
    description = "WiFi password sharing via QR codes";
    homepage = "https://github.com/kokoye2007/wifi-qr";
    license = with licenses; [ gpl3Plus ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ ambroisie ];
  };
}
