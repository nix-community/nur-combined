{
  lib,
  fetchurl,
  stdenvNoCC,
  xorg,
  glib,
  libxkbcommon,
  fontconfig,
  dbus,
  nss,
  nspr,
  at-spi2-core,
  mesa,
  alsa-lib,
  libpulseaudio,
  cairo,
  freetype,
  libdrm,
  libGL,
  libjack2,
  zlib,
  expat,
  pango,
  libgbm,
  dpkg,
  makeShellWrapper,
  commandLineArgs ? "",
}:
let
  pname = "wechat";
  version = "4.1.0.13";
  src = fetchurl {
    url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb";
    hash = "sha256-OYWMSEZj93ObszGswFul2KbrQIEyOvEppqJ4Ff08CqU=";
  };
  inputs = [
    glib.out
    libxkbcommon
    fontconfig
    dbus
    nss
    nspr
    at-spi2-core
    mesa
    alsa-lib
    libpulseaudio
    cairo
    freetype
    libdrm
    libGL
    libjack2
    zlib
    expat
    pango
    libgbm
  ]
  ++ (with xorg; [
    libXcomposite
    libXrender
    libXrandr
    libXext
    libX11
    libXdamage
    libXfixes
    xcbutilwm
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
  ]);

in
stdenvNoCC.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = [
    dpkg
    makeShellWrapper
  ];

  buildInputs = inputs;

  phases = [ "installPhase" ]; # just run installPhase

  installPhase = ''
    dpkg -x $src ./
    mkdir -p $out
    mv ./opt/wechat $out/
    mv ./usr/share $out/share

    substituteInPlace $out/share/applications/wechat.desktop \
      --replace-fail "/usr/bin/wechat" "$out/bin/wechat"
    sed -i "s|^Icon=.*$|Icon=wechat|" $out/share/applications/wechat.desktop

    mkdir -p $out/bin

    makeShellWrapper $out/wechat/wechat $out/bin/wechat \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath (
          inputs
          ++ [
            xorg.libxcb
          ]
        )
      }" \
      --run 'REAL_HOME=$HOME' \
      --run 'TMP_HOME=$REAL_HOME/.config/wechat' \
      --run 'export HOME=$TMP_HOME' \
      --run 'export XDG_CONFIG_HOME=$REAL_HOME/.config' \
      --run 'export XDG_CACHE_HOME=$REAL_HOME/.cache' \
      --run 'export XDG_DATA_HOME=$REAL_HOME/.local/share' \
       \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --add-flags ${lib.escapeShellArg commandLineArgs} \
      --run 'exec $1 "$@"'
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "WeChat for Linux";
    homepage = "https://linux.weixin.qq.com";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = lib.platforms.linux;
  };
}
