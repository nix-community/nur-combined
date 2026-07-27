{
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  lib,
  makeWrapper,
  dbus,
  cairo,
  gtk3,
  pango,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libgbm,
  expat,
  libxcb,
  libxkbcommon,
  libudev-zero,
  alsa-lib,
  at-spi2-atk,
  libgcc,
  nspr,
  nss,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zcode";
  version = "3.3.6";

  src = fetchurl {
    url = "https://cdn-zcode.z.ai/zcode/electron/releases/3.3.6/linux-x64/ZCode-3.3.6-linux-x64.deb";
    sha256 = "sha256-R93tSPSNxdsuH1pVT+qOW7Hxg/otJjaX4vSDephdlf8="; # replace with actual hash: nix-prefetch-url <url> or use lib.fakeHash first
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    dbus
    cairo
    gtk3
    pango
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libgbm
    expat
    libxcb
    libxkbcommon
    libudev-zero
    alsa-lib
    at-spi2-atk
    libgcc
    nspr
    nss
  ];

  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    mv opt/ZCode .
    mv usr/share .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt
    mv ZCode $out/opt/
    mv share $out/share
    substituteInPlace $out/share/applications/zcode.desktop \
      --replace-fail '/opt/ZCode/zcode' "$out/bin/zcode --force-device-scale-factor=1.0"
    mkdir -p $out/bin
    ln -s $out/opt/ZCode/zcode $out/bin/zcode
    runHook postInstall
  '';

 meta = with lib; {
   sourceProvenance = with sourceTypes; [ binaryNativeCode ];
   description = "Zcode, Simple, Fast, Vibe‑Ready ! z.ai agent client";
    homepage = "https://zcode.z.ai";
    license = licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    mainProgram = "zcode";
  };
})
