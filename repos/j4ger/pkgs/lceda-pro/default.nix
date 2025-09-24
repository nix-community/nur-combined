{
  stdenv,
  fetchzip,
  lib,
  makeDesktopItem,
  makeWrapper,
  copyDesktopItems,
  xdg-utils,
  electron,
}:

let
  desktopEntry = makeDesktopItem {
    name = "lceda-pro";
    desktopName = "LCEDA Pro";
    exec = "lceda-pro %u";
    icon = "lceda";
    categories = [ "Development" ];
    extraConfig = {
      "Name[zh_CN]" = "立创EDA专业版";
    };
  };
  electron_runtime = electron;
in
stdenv.mkDerivation rec {
  pname = "lceda-pro";
  version = "2.2.40.8";
  src = fetchzip {
    url = "https://image.lceda.cn/files/lceda-pro-linux-x64-${version}.zip";
    hash = "sha256-6HEkuyCDXnhcYlvvs5M+MyIrHpdfrAsXiuDmPxlEI+c=";
    stripRoot = false;
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $TEMPDIR/lceda-pro
    cp -rf lceda-pro $out/lceda-pro
    mv $out/lceda-pro/resources/app/assets/db/lceda-std.elib $TEMPDIR/lceda-pro/db.elib

    makeWrapper ${electron_runtime}/bin/electron $out/bin/lceda-pro \
      --add-flags $out/lceda-pro/resources/app/ \
      --add-flags "--gtk4 --enable-wayland-ime" \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ stdenv.cc.cc ]}" \
      --set PATH "${lib.makeBinPath [ xdg-utils ]}"

    mkdir -p $out/share/icons/hicolor/512x512/apps
    install -Dm444 $out/lceda-pro/icon/icon_512x512.png $out/share/icons/lceda.png
    install -Dm444 $out/lceda-pro/icon/icon_512x512.png $out/share/icons/hicolor/512x512/apps/lceda.png

    mkdir -p $out/share/applications

    runHook postInstall
  '';

  preFixup = ''
    patchelf \
      --set-rpath "$out/lceda-pro" \
      $out/lceda-pro/lceda-pro
  '';

  desktopItems = [ desktopEntry ];

  meta = with lib; {
    homepage = "https://lceda.cn/";
    description = "A high-efficiency PCB design suite";
    license = licenses.unfree;
    platforms = platforms.linux;
    # maintainers = [ j4ger ];
  };
}
