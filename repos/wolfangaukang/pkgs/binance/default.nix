{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, electron
, alsa-lib
, gtk3
, libxcrypt-legacy
, libxshmfence
, mesa
, nss
, popt
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "binance";
  version = "1.41.0";

  src = fetchurl {
    url = "https://github.com/binance/desktop/releases/download/v${finalAttrs.version}/${finalAttrs.pname}-${finalAttrs.version}-amd64-linux.deb";
    hash = "sha256-lIiucm8wgCen7aMGqww76mIX3wBN29d3Cf6GPksGUKM=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [ alsa-lib gtk3 libxcrypt-legacy libxshmfence mesa nss popt ];

  libPath = lib.makeLibraryPath finalAttrs.buildInputs;

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    dpkg-deb -x ${finalAttrs.src} ./
  '';

  installPhase = ''
    runHook preInstall

    mv usr $out
    mv opt $out

    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace $out/share/applications/binance.desktop --replace '/opt/Binance' $out/bin

    makeWrapper ${electron}/bin/electron \
      $out/bin/binance \
      --add-flags $out/opt/Binance/resources/app.asar \
      --prefix LD_LIBRARY_PATH : ${finalAttrs.libPath}
  '';

  meta = with lib; {
    description = "Binance Cryptoexchange Official Desktop Client";
    homepage = "https://www.binance.com/en/desktop-download";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    maintainers = with maintainers; [ wolfangaukang ];
    platforms = [ "x86_64-linux" ];
  };
})
