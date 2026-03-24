{
  alsa-lib,
  autoPatchelfHook,
  dpkg,
  fetchurl,
  gtk3,
  lib,
  libdrm,
  libGL,
  libgbm,
  libsecret,
  makeWrapper,
  nss,
  stdenvNoCC,
  udev,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "terminus-app";
  version = "9.37.5";

  src = fetchurl {
    url = "https://deb.termius.com/pool/main/t/termius-app/termius-app_${finalAttrs.version}_amd64.deb";
    hash = "sha256-hOTgKHAaai1GjgE0sKIwVtvukokklquFgWkqUnN+egA=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    gtk3
    libdrm
    libgbm
    libsecret
    nss
  ];

  postPatch = ''
    substituteInPlace usr/share/applications/termius-app.desktop \
      --replace-fail "Exec=/opt" "Exec=$out/opt"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r opt usr/share $out/
    ln -s $out/opt/Termius/termius-app $out/bin/

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/opt/Termius/termius-app \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          udev
        ]
      }
  '';

  meta = {
    description = "Desktop SSH Client";
    homepage = "https://termius.com/";
    downloadPage = "https://termius.com/download";
    changelog = "https://termius.com/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "termius-app";
    platforms = [ "x86_64-linux" ];
  };
})
