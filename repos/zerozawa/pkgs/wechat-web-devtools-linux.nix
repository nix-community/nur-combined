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
  libxdamage,
  libxcomposite,
  libxshmfence,
  libxcb,
  libxkbcommon,
  libX11,
  libxext,
  libxfixes,
  libxrandr,
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
}:
let
  aur = stdenv.mkDerivation rec {
    pname = "wechat-devtools-git";
    version = "1e269bd9e5db122148d7199cf788ff1710c69e48";
    src = fetchgit {
      url = "https://aur.archlinux.org/${pname}.git";
      rev = version;
      hash = "sha256-na1wVNB2fEdzaqbaPfkh6HAMWy3VlDwyeiTDrEXVywk=";
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
  version = "2.01.2510290-2";
  src = fetchurl {
    url = "https://github.com/msojocs/${pname}/releases/download/v${version}/WeChat_Dev_Tools_v${version}_x86_64_linux.tar.gz";
    hash = "sha256-LyRXmmhfbTIApzoXU9ayOmfRhVJbtQK2n0pJMwQgMuU=";
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
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
    libxdamage
    libxcomposite
    libxshmfence
  ];

  # 忽略 musl libc，因为这是 @swc/core 的可选依赖
  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
  ];

  installPhase = ''
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
  + (lib.concatStringsSep "\n" (
    lib.map
      (x: ''
        wrapProgram ${x} \
          --prefix LD_LIBRARY_PATH : "$out/opt/${pname}/nwjs/lib" \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs} \
          --set-default XDG_CONFIG_HOME "\$HOME/.config" \
          --set LIBGL_DRIVERS_PATH "${mesa}/lib/dri"
      '')
      [
        "$out/bin/${pname}"
        "$out/bin/${pname}-cli"
      ]
  ))
  + "\nrunHook postInstall";

  meta = with lib; {
    description = "msojocs/wechat-web-devtools-linux: 适用于微信小程序的微信开发者工具 Linux移植版";
    homepage = "https://github.com/msojocs/wechat-web-devtools-linux";
    license = with licenses; [ mit ];
    platforms = with platforms; (intersectLists x86_64 linux);
    mainProgram = pname;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
  };
}
