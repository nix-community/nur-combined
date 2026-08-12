{
  lib,
  fetchurl,
  stdenvNoCC,
  undmg,
  xar,
  cpio,
}:

stdenvNoCC.mkDerivation {
  pname = "google-japanese-input";
  # check https://support.google.com/gboard/community for the new version
  version = "2.30.5590.1";

  src = fetchurl {
    # older version might be downloaded from https://dl.google.com/japanese-ime/${version}/GoogleJapaneseInput.dmg
    url = "https://web.archive.org/web/20250202161940/https://dl.google.com/japanese-ime/latest/GoogleJapaneseInput.dmg";
    hash = "sha256-btmy5qTtS9LqT0WS+NBkVneMpGrdYVre28zyRoD/WSg=";
  };

  unpackPhase = ''
    runHook preUnpack

    undmg $src
    mv GoogleJapaneseInput.pkg GoogleJapaneseInputOrig.pkg
    xar -xf GoogleJapaneseInputOrig.pkg
    rm GoogleJapaneseInputOrig.pkg
    pushd GoogleJapaneseInput.pkg
    zcat Payload | cpio -i
    popd

    runHook postUnpack
  '';

  nativeBuildInputs = [
    cpio
    undmg
    xar
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r GoogleJapaneseInput.pkg/{Applications,Library} $out

    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace $out/Library/LaunchAgents/com.google.inputmethod.Japanese.Converter.plist \
      --replace-fail "/Library" "$out/Library"
    substituteInPlace $out/Library/LaunchAgents/com.google.inputmethod.Japanese.Renderer.plist \
      --replace-fail "/Library" "$out/Library"
  '';

  meta = {
    description = "Japanese Input Method Editor";
    homepage = "https://www.google.co.jp/ime";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
  };
}
