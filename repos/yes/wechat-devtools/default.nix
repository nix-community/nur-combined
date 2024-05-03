{ lib
, appimageTools
, fetchurl
, rp ? ""
}:
let
  pname = "wechat-devtools";
  version = "1.06.2402040-1";

  src = fetchurl {
    url = "${rp}https://github.com/msojocs/wechat-web-devtools-linux/releases/download/v${version}/WeChat_Dev_Tools_v${version}_x86_64_linux.AppImage";
    hash = "sha256-vbKamBPNG9ezpy/wou1LgSLJPmS5N+u28+20s49h+u0=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    DESKTOP_FILE=io.github.msojocs.wechat_devtools.desktop

    install -Dm 444 ${appimageContents}/$DESKTOP_FILE -t $out/share/applications
    install -Dm 444  ${appimageContents}/${pname}.png -t $out/share/pixmaps

    substituteInPlace $out/share/applications/$DESKTOP_FILE \
      --replace 'Exec=bin/${pname}' 'Exec=${pname}'
  '';

  meta = with lib; {
    description = "WeChat Devtools For Linux";
    homepage = "https://github.com/msojocs/wechat-web-devtools-linux";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}