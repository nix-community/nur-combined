{
  lib,
  fetchzip,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fcitx5-pinyin-custom-dictionary";
  version = "unstable-2025-01-01";
  date = "20250101";

  src = fetchzip {
    url = "https://github.com/wuhgit/CustomPinyinDictionary/releases/download/assets/CustomPinyinDictionary_Fcitx_${finalAttrs.date}.tar.gz";
    hash = "sha256-aW7q+qNdN/KoCLM0F3xoZVQmQITKc5U2vyYECn/sdPo=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 $src/CustomPinyinDictionary_Fcitx.dict $out/share/fcitx5/pinyin/dictionaries/CustomPinyinDictionary_Fcitx.dict

    runHook postInstall
  '';

  meta = {
    description = "Self-built pinyin input method vocabulary library, with a million commonly used words.";
    homepage = "https://github.com/wuhgit/CustomPinyinDictionary";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.all;
  };
})
