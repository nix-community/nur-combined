{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, alsa-lib
, at-spi2-atk
, at-spi2-core
, cairo
, cups
, dbus
, expat
, glib
, gtk3
, libdrm
, libxkbcommon
, mesa
, nspr
, nss
, pango
, systemd
, xorg
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "clash-party";
  version = "1.9.6";

  src = fetchurl {
    url = "https://github.com/mihomo-party-org/clash-party/releases/download/v${version}/mihomo-party-linux-${version}-amd64.deb";
    sha256 = "9fc15417432eafa51dad21217f557c5c4b0292f814e76ffdc6a453a451f581ea";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib at-spi2-atk at-spi2-core cairo cups dbus expat glib gtk3
    libdrm libxkbcommon mesa nspr nss pango systemd xorg.libX11
    xorg.libXcomposite xorg.libXdamage xorg.libXext xorg.libXfixes
    xorg.libXrandr xorg.libxcb
  ];

  unpackPhase = "dpkg -x $src .";

  installPhase = ''
    mkdir -p $out/bin $out/opt
    cp -r opt/clash-party $out/opt/
    cp -r usr/share $out/share

    # 链接启动文件
    ln -s $out/opt/clash-party/mihomo-party $out/bin/mihomo-party

    # 修正桌面图标路径 (添加 || true 防止替换失败)
    substituteInPlace $out/share/applications/mihomo-party.desktop \
      --replace "/opt/clash-party/mihomo-party" "mihomo-party" || true
  '';

  meta = with lib; {
    description = "Another graphical clash-core and mihomo-core client";
    homepage = "https://github.com/mihomo-party-org/mihomo-party";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
