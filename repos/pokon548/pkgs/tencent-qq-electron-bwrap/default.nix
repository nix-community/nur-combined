{ appimageTools, lib, fetchurl, electron, makeWrapper, libsecret }:

let
  pname = "qq";
  version = "2.0.1-429";
  name = "Tencent-QQ-${version}-bwrap";

  src = fetchurl {
    url = "https://dldir1.qq.com/qqfile/qq/QQNT/4691a571/QQ-v${version}_x64.AppImage";
    sha256 = "sha256-7izsmUwfEAcQHj6PNcU/cprJRNHj342I62kW316vKo8=";
  };

  appimageContents = appimageTools.extract { inherit name src; };

in appimageTools.wrapType2 {
  inherit version name src;

  # Below we substitute auto_mounts to no_automounts
  # to avoid applying default bingding rules (mount everything on /)
  # then we add extra things to make it works...
  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}' \
      --replace 'Icon=/opt/QQ/resources/app/512x512.png' 'Icon=qq'
    
    cp $out/bin/${pname} $out/bin/test
    mv $out/bin/test $out/bin/${pname}
    substituteInPlace $out/bin/${pname} \
      --replace "auto_mounts[@]" 'no_automounts[@]'

    sed -i '102 i \ \ --ro-bind /sys /sys' $out/bin/${pname}
    sed -i '102 i \ \ --dev-bind /run/dbus /run/dbus' $out/bin/${pname}
    sed -i '102 i \ \ --bind /run/user/\$(id -u) /run/user/\$(id -u)' $out/bin/${pname}
    sed -i '102 i \ \ --ro-bind-try /etc/fonts /etc/fonts' $out/bin/${pname}
    sed -i '102 i \ \ --bind /tmp /tmp' $out/bin/${pname}
    sed -i '102 i \ \ --bind "\$HOME/.pki" "\$HOME/.pki"' $out/bin/${pname}
    sed -i '102 i \ \ --ro-bind "\$HOME/.Xauthority" "\$HOME/.Xauthority"' $out/bin/${pname}
    sed -i '102 i \ \ --bind "\$(xdg-user-dir)/.config/QQ" "\$(xdg-user-dir)/.config/QQ"' $out/bin/${pname}
    sed -i '102 i \ \ --bind "\$(xdg-user-dir DOWNLOAD)" "\$(xdg-user-dir DOWNLOAD)"' $out/bin/${pname}
    sed -i '102 i \ \ --bind "/run/opengl-driver/" "/run/opengl-driver/"' $out/bin/${pname}
    sed -i '102 i \ \ --setenv IBUS_USE_PORTAL 1' $out/bin/${pname}

    sed -i '102 i \ \ --ro-bind "\$HOME/.icons" "\$HOME/.icons"' $out/bin/${pname}

    cp -r ${appimageContents}/usr/share/icons $out/share
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
