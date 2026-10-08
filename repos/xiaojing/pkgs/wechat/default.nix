{
  lib,
  fetchurl,
  appimageTools
}:
let
  pname = "wechat";
  version = "4.1.13.23";

  meta = {
    description = "Messaging and calling app";
    homepage = "https://www.wechat.com/en/";
    downloadPage = "https://linux.weixin.qq.com/en";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [
      xiaojing
    ];
    mainProgram = "wechat";
    platforms = [
      "x86_64-linux"
    ];
  };
  
  src = fetchurl {
    url = "https://github.com/Rodert/wechat-linux-versions/releases/download/v4.1.13.23/WeChatLinux_x86_64.AppImage";
    hash = "sha256-T1StKQLs1vb9xWgLc1R/gNVCO/RwsBI3pXmi5bPK7us=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
    postExtract = ''
      patchelf --replace-needed libtiff.so.5 libtiff.so $out/opt/wechat/wechat
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version meta;

  src = appimageContents;

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${appimageContents}/wechat.desktop $out/share/applications/
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp ${appimageContents}/wechat.png $out/share/icons/hicolor/256x256/apps/

    substituteInPlace $out/share/applications/wechat.desktop --replace-fail AppRun wechat
  '';
}
