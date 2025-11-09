{
  stdenv,
  sources,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeWrapper,
  lib,
  # Dependencies
  alsa-lib,
  gtk3,
  krb5,
  libdrm,
  libgcrypt,
  libpulseaudio,
  libva,
  mesa,
  nspr,
  nss,
  pciutils,
  systemd,
  xorg,
}:
let
  libraries = [
    alsa-lib
    gtk3
    krb5
    libdrm
    libgcrypt
    libpulseaudio
    libva
    mesa
    nspr
    nss
    pciutils
    systemd
    xorg.libXdamage
  ];

  source =
    if stdenv.isx86_64 then
      sources.qq-amd64
    else if stdenv.isAarch64 then
      sources.qq-arm64
    else
      throw "Unsupported architecture";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "qq";
  version = builtins.elemAt (lib.splitString "_" source.version) 1;
  inherit (source) src;

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    makeWrapper
  ];
  buildInputs = libraries;

  unpackPhase = ''
    runHook preUnpack

    ar x $src

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    tar xf data.tar.xz -C $out
    mv $out/usr/* $out/
    mv $out/opt/QQ/* $out/opt/
    rm -rf $out/opt/QQ $out/usr

    makeWrapper $out/opt/qq $out/bin/qq \
      --argv0 "qq" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}"

    sed -i "s|Exec=.*|Exec=$out/bin/qq|" $out/share/applications/qq.desktop
    sed -i "s|Icon=.*|Icon=qq|" $out/share/applications/qq.desktop

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Desktop client for QQ on Linux";
    homepage = "https://im.qq.com/linuxqq/index.html";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "qq";
  };
})
