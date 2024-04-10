{ lib
, stdenv
, appimageTools
, fetchurl
}: let
  pname = "hiddify";
  version = "1.1.1";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/hiddify/hiddify-next/releases/download/v${version}/Hiddify-Linux-x64.AppImage";
    hash = "sha256-T4BWxhJ7q13KE1rvvFsnXhs2XVEmNkFTJbJ4e8PCg+0=";
  };
  hiddify = appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs: with pkgs; [ 
      libepoxy
    ];
  };

in stdenv.mkDerivation rec {
  inherit pname version;

  dontUnpack = true;

  appimageContents = appimageTools.extractType2 {
    inherit name src;
  };

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    cp ${hiddify}/bin/${name} $out/bin/hiddify
    cp -a ${appimageContents}/${pname}.desktop $out/share/applications/
    cp -a ${appimageContents}/usr/share/icons $out/share/

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'LD_LIBRARY_PATH=usr/lib ' ''''''
    runHook postInstall
  '';

  meta = with lib; {
    description = "Multi-platform auto-proxy client (appimage version)";
    longDescription = ''
      Multi-platform auto-proxy client, supporting Sing-box, X-ray, TUIC, Hysteria, Reality, Trojan, SSH etc. It’s an open-source, secure and ad-free.
    '';
    homepage = "https://github.com/hiddify/hiddify-next";
    license = licenses.cc-by-nc-sa-40;
    platforms = [ "x86_64-linux" ];
  };
}
