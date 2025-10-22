# https://aur.archlinux.org/wechat-devtools-git.git
{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  fetchgit,
  autoPatchelfHook,
  glib,
  nss,
  nspr,
  at-spi2-core,
  cups,
  libdrm,
  dbus,
  expat,
  alsa-lib,
  xorg,
  libxcb ? xorg.libxcb,
  libxkbcommon,
  libX11 ? xorg.libX11,
  libxext ? xorg.libXext,
  libxfixes ? xorg.libXfixes,
  libxrandr ? xorg.libXrandr,
  libgbm,
  pango,
  cairo,
  gtk3,
  libxkbfile,
  krb5,
  systemd,
  mesa,
  curl,
  ...
}: let
  aur = stdenv.mkDerivation rec {
    pname = "wechat-devtools-git";
    version = "cda885a20b6aedfbd30703c0ccf1bed88829b58f";
    src = fetchgit {
      url = "https://aur.archlinux.org/${pname}.git";
      rev = version;
      hash = "sha256-wFXoZtsLmpztx/GOH1gXYdjcDVjuVh8JWZQGmK1zssw=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r ./* $out
      runHook postInstall
    '';
  };
in
  stdenv.mkDerivation rec {
    pname = "wechat-web-devtools-linux";
    version = "1.06.2504030-1";
    src = fetchurl {
      url = "https://github.com/msojocs/${pname}/releases/download/v${version}/WeChat_Dev_Tools_v${version}_x86_64_linux.tar.gz";
      hash = "sha256-hvAPPDnJjzxH6nU8VNRafwVjoYiTDrFKqWPnzq+t3d4=";
    };

    nativeBuildInputs = [
      makeWrapper
      autoPatchelfHook
    ];

    buildInputs =
      [
        glib
        nss
        nspr
        at-spi2-core
        cups
        libdrm
        dbus
        expat
        alsa-lib
        libxcb
        libxkbcommon
        libxkbfile
        libX11
        libxext
        libxfixes
        libxrandr
        libgbm
        pango
        cairo
        gtk3
        krb5
        systemd
        mesa
        curl
      ]
      ++ (with xorg; [
        libXdamage
        libXcomposite
        libxshmfence
      ]);

    # 忽略 musl libc，因为这是 @swc/core 的可选依赖
    autoPatchelfIgnoreMissingDeps = [
      "libc.musl-x86_64.so.1"
    ];

    installPhase =
      ''
        runHook preInstall
        install -d "$out/opt/${pname}"
        install -d "$out/bin"
        install -d "$out/share/applications"
        install -d "$out/share/icons"
        cp -r ./* "$out/opt/${pname}"
        install -Dm644 "${aur}/wechat-devtools.desktop" "$out/share/applications/${pname}.desktop"
        install -Dm644 "${aur}/wechat-devtools.png" "$out/share/icons/${pname}.png"
        ln -s $out/opt/${pname}/bin/wechat-devtools $out/bin/${pname}
        ln -s $out/opt/${pname}/bin/wechat-devtools-cli $out/bin/${pname}-cli
        substituteInPlace $out/share/applications/${pname}.desktop \
          --replace-fail wechat-devtools ${pname}
      ''
      + (lib.concatStringsSep "\n" (lib.map (x: ''
        wrapProgram ${x} \
          --prefix LD_LIBRARY_PATH : "$out/opt/${pname}/nwjs/lib" \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs} \
          --set-default XDG_CONFIG_HOME "\$HOME/.config" \
          --set LIBGL_DRIVERS_PATH "${mesa}/lib/dri"
      '') ["$out/bin/${pname}" "$out/bin/${pname}-cli"]))
      + "\nrunHook postInstall";

    meta = with lib; {
      description = "msojocs/wechat-web-devtools-linux: 适用于微信小程序的微信开发者工具 Linux移植版";
      homepage = "https://github.com/msojocs/wechat-web-devtools-linux";
      license = with licenses; [mit];
      platforms = with platforms; (intersectLists x86_64 linux);
      mainProgram = pname;
      sourceProvenance = with sourceTypes; [binaryBytecode];
    };
  }
