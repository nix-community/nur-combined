{
  lib,
  u-he,

  unzip,
}:
u-he.mkUhe (finalAttrs: {
  pname = "u-he-zebra-legacy";
  version = "294_16765";

  product = "Zebra2";
  hash = "sha256-etzkLGpw9yRkgC5O0+nw0LC+Sb230Cm69y4rEF9FxCo=";
  updateName = "Zebra_Legacy";
  extension = "zip";

  nativeBuildInputs = [ unzip ];

  preBuild = ''
    tar -xf 01\ Zebra2/*.xz
    cp -r Zebra2*/Zebra2 .
  '';
  postBuild = ''
    tar -xf 02\ The\ Dark\ Zebra/*.tar.xz
    cp -r ZebraHZ*/ZebraHZ/* $out/libexec/Zebra2/

    mkdir -p $out/libexec/Zebra2/Presets/{ZRev,ZebraHZ}/MIDI\ Programs

    ${lib.getExe u-he.patchelf-raphi} \
      --replace-symbol snprintf snprintf_wrapper \
      --add-needed snprintf_wrapper_Zebra2.so \
      $out/libexec/Zebra2/ZebraHZ.64.so

    ln -s $out/libexec/Zebra2/ZebraHZ.64.so $out/lib/vst/ZebraHZ.so
    mkdir -p $out/lib/vst3/ZebraHZ.vst3/Contents/{x86_64-linux,Resources/Documentation}
    ln -s $out/libexec/Zebra2/ZebraHZ.64.so $out/lib/vst3/ZebraHZ.vst3/Contents/x86_64-linux/ZebraHZ.so
    ln -s $out/libexec/Zebra2/*.pdf $out/lib/vst3/ZebraHZ.vst3/Contents/Resources/Documentation/

    for soundset in 03\ Zebra\ Legacy\ Soundsets/*.uhe-soundset; do
      unzip -o "$soundset" -d $out/libexec/Zebra2
    done
  '';

  meta = {
    homepage = "https://u-he.com/products/zebra-legacy/";
    description = "The workhorse synth";
  };
})
