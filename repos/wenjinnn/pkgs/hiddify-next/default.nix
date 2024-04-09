{ lib
, stdenv
, appimageTools
, copyDesktopItems
, makeDesktopItem
, fetchurl
}: let
  pname = "hiddify";
  version = "1.1.1";
  name = "${pname}-${version}";
  hiddify = appimageTools.wrapType2 rec {
    inherit pname version;
    src = fetchurl {
      url = "https://github.com/hiddify/hiddify-next/releases/download/v${version}/Hiddify-Linux-x64.AppImage";
      hash = "sha256-T4BWxhJ7q13KE1rvvFsnXhs2XVEmNkFTJbJ4e8PCg+0=";
    };

    extraPkgs = pkgs: with pkgs; [ 
      libepoxy
    ];

  };

in stdenv.mkDerivation rec {
  inherit pname version;
  dontUnpack = true;

  nativeBuildInputs = [ copyDesktopItems ];
  desktopItems = [
    (makeDesktopItem rec {
      name = pname;
      desktopName = "Hiddify";
      genericName = desktopName;
      comment = meta.description;
      exec = "${pname} %u";
      icon = pname;
      terminal = false;
      type = "Application";
      categories = [ "Network" ];
      keywords = [ desktopName ];
    })
  ];

  # TODO: Extract cura-icon from AppImage source.
  installPhase = ''
    mkdir -p $out/bin
    cp ${hiddify}/bin/${name} $out/bin/hiddify
    runHook postInstall
  '';

  meta = with lib; {
    description = "(appimage version) Multi-platform auto-proxy client, supporting Sing-box, X-ray, TUIC, Hysteria, Reality, Trojan, SSH etc. It’s an open-source, secure and ad-free.";
    homepage = "https://github.com/hiddify/hiddify-next";
    license = licenses.cc-by-nc-sa-40;
    platforms = [ "x86_64-linux" ];
  };

}
