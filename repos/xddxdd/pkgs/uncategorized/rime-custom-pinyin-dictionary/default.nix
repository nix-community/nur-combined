{
  fetchurl,
  lib,
  stdenv,
  libime,
  imewlconverter,
  unzip,
}:
# Based on https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=rime-custom-pinyin-dictionary
stdenv.mkDerivation (finalAttrs: {
  pname = "rime-custom-pinyin-dictionary";
  version = "20260101";
  src = fetchurl {
    url = "https://github.com/wuhgit/CustomPinyinDictionary/releases/download/assets/CustomPinyinDictionary_Fcitx_Magisk_${finalAttrs.version}.zip";
    hash = "sha256-0+da8NepstQWR3YIJRgoF5bGokqFRxqLfPKS9EPya6k=";
  };
  sourceRoot = ".";

  nativeBuildInputs = [
    libime
    imewlconverter
    unzip
  ];

  buildPhase = ''
    runHook preBuild

    cp dict/data CustomPinyinDictionary_Fcitx.dict
    libime_pinyindict -d CustomPinyinDictionary_Fcitx.dict temp.txt
    ImeWlConverterCmd -i libpy -o rime -O CustomPinyinDictionary.dict.yaml temp.txt

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp CustomPinyinDictionary.dict.yaml $out/share/rime-data/CustomPinyinDictionary.dict.yaml

    runHook postInstall
  '';

  passthru.updateScript = [ (toString ./update.sh) ];
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "自建拼音输入法词库，百万常用词汇量，适配 Fcitx5 (Linux / Android) 及 Gboard (Android + Magisk or KernelSU) 。";
    homepage = "https://github.com/wuhgit/CustomPinyinDictionary";
    license = lib.licenses.unfree;
  };
})
