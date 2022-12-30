{ appimageTools, lib, fetchurl, fetchzip, electron, makeWrapper, libsecret, p7zip }:

let
  pname = "qq";
  version = "3.0.0-565";
  name = "Tencent-QQ-${version}-bwrap";

  srcs = {
    electron = fetchurl {
      url = "https://dldir1.qq.com/qqfile/qq/QQNT/50eed662/QQ-v2.0.3-543_x64.AppImage";
      sha256 = "sha256-QtoTFMwYNFBtT1Gq3tB529Zg5PCicn15EOOgzmUb5WA=";
    };

    hotpatch = fetchzip {
      url = "https://qqpatch.gtimg.cn/hotUpdate_new/release/linux-x64/${version}/${version}.zip.zip";
      name = "hotpatch-qq-${version}";
      sha256 = "sha256-MwhzyeI6Pmhpr9LAZT5nZjMXgSN8ntCCcB3njzwe/r0=";
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
    substituteInPlace $out/bin/${pname} \
      --replace "auto_mounts[@]" 'no_automounts[@]'
    sed -i '105 i \ \ --ro-bind /sys /sys' $out/bin/${pname}
    sed -i '105 i \ \ --dev-bind /run/dbus /run/dbus' $out/bin/${pname}
    sed -i '105 i \ \ --bind /run/user/$(id -u) /run/user/$(id -u)' $out/bin/${pname}
    sed -i '105 i \ \ --ro-bind-try /etc/fonts /etc/fonts' $out/bin/${pname}
    sed -i '105 i \ \ --dev-bind /tmp /tmp' $out/bin/${pname}
    sed -i '105 i \ \ --bind "\$HOME/.pki" "\$HOME/.pki"' $out/bin/${pname}
    sed -i '105 i \ \ --ro-bind "\$HOME/.Xauthority" "\$HOME/.Xauthority"' $out/bin/${pname}
    sed -i '105 i \ \ --bind "$(xdg-user-dir)/.config/QQ" "$(xdg-user-dir)/.config/QQ"' $out/bin/${pname}
    sed -i '105 i \ \ --bind "$(xdg-user-dir DOWNLOAD)" "$(xdg-user-dir DOWNLOAD)"' $out/bin/${pname}
    sed -i '105 i \ \ --bind "/run/opengl-driver/" "/run/opengl-driver/"' $out/bin/${pname}
    sed -i '105 i \ \ --setenv IBUS_USE_PORTAL 1' $out/bin/${pname}
    sed -i '105 i \ \ --setenv GTK_IM_MODULE $GTK_IM_MODULE' $out/bin/${pname}
    sed -i '105 i \ \ --setenv DISPLAY $\{DISPLAY}' $out/bin/${pname}
    sed -i '105 i \ \ --bind /run/current-system/sw /run/current-system/sw' $out/bin/${pname}
    sed -i '105 i \ \ --ro-bind "\$HOME/.icons" "\$HOME/.icons"' $out/bin/${pname}
    sed -i '105 i \ \ --ro-bind "$(xdg-user-dir)/.local/share/fcitx5" "$(xdg-user-dir)/.local/share/fcitx5"' $out/bin/${pname}
  '';

  #passthru.version = version;

  extraPkgs = pkgs: with pkgs; [
    libsecret
    libappindicator-gtk3
  ];

  meta = with lib; {
    homepage = "https://im.qq.com";
    description = "Official Tencent QQ client for Linux (Beta) with enhanced bwrap rules";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
  };
}
