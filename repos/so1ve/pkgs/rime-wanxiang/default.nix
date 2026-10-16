{
  callPackage,
  lib,
  opencc,
  source ? callPackage ./source.nix { },
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rime-wanxiang";
  inherit (source) version src;

  nativeBuildInputs = [ opencc ];

  buildPhase = ''
    runHook preBuild

    for dictionary in emoji STCharacters STPhrases HKVariants TWVariants; do
      dictionary_file="opencc/wanxiang/$dictionary.txt"
      sed -i '/^#/d' "$dictionary_file"
      opencc_dict -i "$dictionary_file" -o "opencc/wanxiang/$dictionary.ocd2" -f text -t ocd2
      rm "$dictionary_file"
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/rime-data"
    cp -r dicts lua opencc *.yaml custom_phrase.txt version.txt "$out/share/rime-data/"
    mv "$out/share/rime-data/default.yaml" "$out/share/rime-data/wanxiang_suggested_default.yaml"

    runHook postInstall
  '';

  meta = {
    description = "Wanxiang Pinyin schemas and dictionaries for Rime";
    homepage = "https://github.com/amzxyz/rime-wanxiang";
    changelog = "https://github.com/amzxyz/rime-wanxiang/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.cc-by-40;
    platforms = lib.platforms.all;
  };
})
