{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation {
  pname = "harmonyos-sans";
  version = "1.0"; # from font metadata

  src = fetchzip {
    url = "https://developer.huawei.com/images/download/general/HarmonyOS-Sans.zip";
    hash = "sha256-c10AIlce3WSqzKI9cq9LoobRJHgbqnzBo/d958Acz/A=";
    stripRoot = false;
  };

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  doCheck = false;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/truetype HarmonyOS\ Sans/HarmonyOS_Sans*/HarmonyOS_Sans_*.ttf

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://developer.huawei.com/consumer/cn/design/resource/";
    description = "HarmonyOS Sans font";
    platforms = platforms.all;
    license = licenses.unfree;
  };
}
