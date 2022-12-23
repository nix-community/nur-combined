{ appimageTools, lib, fetchurl, fetchzip, electron, makeWrapper, libsecret, p7zip }:

let
  pname = "qq";
  version = "2.0.3-543";
  name = "Tencent-QQ-${version}";

  srcs = {
    electron = fetchurl {
      url = "https://dldir1.qq.com/qqfile/qq/QQNT/4691a571/QQ-v2.0.1-429_x64.AppImage";
      sha256 = "sha256-7izsmUwfEAcQHj6PNcU/cprJRNHj342I62kW316vKo8=";
    };

    hotpatch = fetchzip {
      url = "https://qqpatch.gtimg.cn/hotUpdate_new/release/linux-x64/${version}/${version}.zip.zip";
      name = "hotpatch-qq-${version}";
      sha256 = "sha256-Uhg3mR79q4YY+oq1TehfBHz8s1Aay1t6WzaZul3EUTw=";
    };
  };
  
  src = srcs.electron;

  appimageContents = (appimageTools.extract { inherit name src; }).overrideAttrs (oA: {
    # Dirty workaround for hot updates
    nativeBuildInputs = [ p7zip ];

    configJson = ./config.json;

    buildCommand = ''
      ${oA.buildCommand}

      rm -rf $out/resources/app
      7z x ${srcs.hotpatch}/${version}.zip -aoa -o$out/resources/app
      chmod 755 $out/resources/app

      mkdir -p $out/workarounds
      cp ${configJson} $out/workarounds/config.json
    '';
  });

  configJson = ./config.json;

in appimageTools.wrapAppImage {
  inherit version name;
  src = appimageContents;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}' \
      --replace 'Icon=/opt/QQ/resources/app/512x512.png' 'Icon=qq'
    cp -r ${appimageContents}/usr/share/icons $out/share

    cp $out/bin/${pname} $out/bin/test
    mv $out/bin/test $out/bin/${pname}

    sed -i '39 i ! [ -f "$(xdg-user-dir)/.config/QQ/versions/config.json" ] && (mkdir -pv $(xdg-user-dir)/.config/QQ/versions/ && cp ${appimageContents}/workarounds/config.json $(xdg-user-dir)/.config/QQ/versions/)' $out/bin/${pname}
    sed -i '40 i ! [ -d "$(xdg-user-dir)/.config/QQ/versions/${version}" ] && mkdir -pv $(xdg-user-dir)/.config/QQ/versions/${version}' $out/bin/${pname}
    sed -i '41 i ! [ -d "$(xdg-user-dir)/.config/QQ/versions/${version}/about" ] && ln -s ${appimageContents}/resources/app/* $(xdg-user-dir)/.config/QQ/versions/${version}' $out/bin/${pname}
  '';

  #passthru.version = version;

  extraPkgs = pkgs: with pkgs; [
    libsecret
    libappindicator-gtk3
  ];

  meta = with lib; {
    homepage = "https://im.qq.com";
    description = "Official Tencent QQ client for Linux (Beta)";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
  };
}
