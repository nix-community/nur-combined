{
  stdenv,
  sources,
  autoPatchelfHook,
  wrapGAppsHook,
  makeWrapper,
  lib,
  # Dependencies
  alsa-lib,
  gtk3,
  krb5,
  libdrm,
  libgcrypt,
  libva,
  mesa,
  nspr,
  nss,
  pciutils,
  systemd,
  xorg,
  ...
} @ args: let
  libraries = [
    alsa-lib
    gtk3
    krb5
    libdrm
    libgcrypt
    libva
    mesa.drivers
    nspr
    nss
    pciutils
    systemd
    xorg.libXdamage
  ];

  source =
    if stdenv.isx86_64
    then sources.qq-amd64
    else if stdenv.isAarch64
    then sources.qq-arm64
    else throw "Unsupported architecture";
in
  stdenv.mkDerivation rec {
    pname = "qq";
    version = builtins.elemAt (lib.splitString "_" source.version) 1;
    inherit (source) src;

    nativeBuildInputs = [autoPatchelfHook wrapGAppsHook makeWrapper];
    buildInputs = libraries;

    unpackPhase = ''
      ar x ${src}
    '';

    installPhase = ''
      mkdir -p $out/bin
      tar xf data.tar.xz -C $out
      mv $out/usr/* $out/
      mv $out/opt/QQ/* $out/opt/
      rm -rf $out/opt/QQ $out/usr

      makeWrapper $out/opt/qq $out/bin/qq \
        --argv0 "qq" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}"

      sed -i "s|Exec=.*|Exec=$out/bin/qq|" $out/share/applications/qq.desktop
      sed -i "s|Icon=.*|Icon=$out/opt/resources/app/512x512.png|" $out/share/applications/qq.desktop
    '';

    meta = with lib; {
      description = "QQ for Linux";
      homepage = "https://im.qq.com/linuxqq/index.html";
      platforms = ["x86_64-linux" "aarch64-linux"];
      license = licenses.unfreeRedistributable;
    };
  }
