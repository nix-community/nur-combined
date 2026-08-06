{ android-translation-layer }:

android-translation-layer.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./android-translation-layer-bitmap-unlock.patch
    ./android-translation-layer-kotatsu-stub.patch
    ./android-translation-layer-mr290.patch
    ./android-translation-layer-fdroid-stub.patch
  ];
})
