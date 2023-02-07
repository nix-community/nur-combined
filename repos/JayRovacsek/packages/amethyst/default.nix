{ lib, stdenv, fetchurl, makeWrapper, makeDesktopItem, graphicsmagick
, writeScript, unzip }:

stdenv.mkDerivation rec {
  pname = "amethyst";
  version = "0.16.0";
  appname = "Amethyst";
  sourceRoot = "${appname}.app";
  nativeBuildInputs = [ makeWrapper unzip ];

  filename = "Amethyst.zip";
  src = fetchurl {
    url =
      "https://github.com/ianyh/Amethyst/releases/download/v${version}/${filename}";
    sha256 = "sha256-pghX74T0JsAWkxAaAaQ5NIhYqj89fo0ZqRtxPThJZ/M=";
  };

  icon = fetchurl {
    url = "https://ianyh.com/images/amethyst.png";
    sha256 = "96169f4d2ea0e9a1283404b4a4309b53a8ca12e5f3169c9f2d1cd1a99a4d4c04";
  };

  desktopItem = makeDesktopItem {
    name = "amethyst";
    desktopName = "Amethyst";
    comment = "Tiling window manager for macOS along the lines of xmonad.";
    icon = "amethyst";
    exec = "amethyst %u";
    categories = [ "Office" ];
    mimeTypes = [ "x-scheme-handler/amethyst" ];
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{Applications/${appname}.app,bin}
    cp -R . $out/Applications/${appname}.app
    makeWrapper $out/Applications/${appname}.app/Contents/MacOS/${appname} $out/bin/${pname}
    runHook postInstall
  '';

  meta = with lib; {
    description = "Tiling window manager for macOS along the lines of xmonad.";
    platforms = platforms.darwin;
    homepage = "https://ianyh.com/amethyst/";
    downloadPage = "https://github.com/ianyh/Amethyst/releases";
    license = licenses.mit;
  };
}
