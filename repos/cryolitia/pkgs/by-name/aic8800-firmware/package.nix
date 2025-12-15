{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  name = "aic8800-firmware";
  version = "0-unstable";

  src = fetchFromGitHub {
    owner = "deepin-community";
    repo = "aic8800";
    rev = "0cf6ce9bdf3593e1a67e646973178464e0af8c20";
    hash = "sha256-+11G7sKfsbIuh4w0fRuxHSjFigYEX5iSmtxAWG0cxXw=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/firmware/aic8800_fw/
    cp -rv firmware/* $out/lib/firmware/aic8800_fw/

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/radxa-pkg/aic8800";
    description = "Aicsemi aic8800 Wi-Fi driver firmware";
    # https://github.com/radxa-pkg/aic8800/issues/54
    license = with lib.licenses; [
      gpl2Only
    ];
    maintainers = with lib.maintainers; [ Cryolitia ];
    platforms = lib.platforms.linux;
  };
}
