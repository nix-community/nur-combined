{
  sources,
  lib,
  stdenvNoCC,
  libime,
  imewlconverter,
}:
# Based on https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=rime-custom-pinyin-dictionary
stdenvNoCC.mkDerivation {
  inherit (sources.rime-custom-pinyin-dictionary) pname version src;

  sourceRoot = ".";

  nativeBuildInputs = [
    libime
    imewlconverter
  ];

  buildPhase = ''
    runHook preBuild

    libime_pinyindict -d CustomPinyinDictionary_Fcitx.dict temp.txt
    ImeWlConverterCmd -i:libpy temp.txt -o:rime CustomPinyinDictionary.dict.yaml

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp CustomPinyinDictionary.dict.yaml $out/share/rime-data/CustomPinyinDictionary.dict.yaml

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "自建拼音输入法词库，百万常用词汇量，适配 Fcitx5 (Linux / Android) 及 Gboard (Android + Magisk or KernelSU) 。";
    homepage = "https://github.com/wuhgit/CustomPinyinDictionary";
    license = licenses.unfree;
  };
}
