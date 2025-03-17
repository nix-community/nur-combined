{
  source,
  stdenvNoCC,
  lib,
}:

stdenvNoCC.mkDerivation {
  inherit (source) pname version src;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp $src $out/share/rime-data/moegirl.dict.yaml

    runHook postInstall
  '';

  meta = {
    description = "RIME dictionary file for entries from zh.moegirl.org.cn";
    homepage = "https://github.com/outloudvi/mw2fcitx";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ xyenon ];
  };
}
