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
    rev = "4.0+git20250410.b99ca8b6-5-0deepin1";
    hash = "sha256-KckJo0883cc2SRhuJYEU5CZ3ffR6G67z54G2LuuvIz4=";
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
