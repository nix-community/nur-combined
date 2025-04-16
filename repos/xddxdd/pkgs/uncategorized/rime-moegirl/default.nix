{
  stdenvNoCC,
  sources,
  lib,
}:
stdenvNoCC.mkDerivation rec {
  inherit (sources.rime-moegirl) pname version src;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp $src $out/share/rime-data/moegirl.dict.yaml

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/outloudvi/mw2fcitx/releases/tag/${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "RIME dictionary file for entries from zh.moegirl.org.cn";
    homepage = "https://github.com/outloudvi/mw2fcitx/releases";
    license = lib.licenses.unlicense;
  };
}
