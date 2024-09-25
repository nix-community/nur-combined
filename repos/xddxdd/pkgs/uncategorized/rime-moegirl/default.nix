{
  stdenvNoCC,
  sources,
  lib,
  ...
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

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Releases for dict of zh.moegirl.org.cn";
    homepage = "https://github.com/outloudvi/mw2fcitx/releases";
    license = licenses.unlicense;
  };
}
