{ android-translation-layer, art-standalone_patched }:

(android-translation-layer.override {
  art-standalone = art-standalone_patched;
}).overrideAttrs
  (old: {
    patches = (old.patches or [ ]) ++ [
      ./android-translation-layer-bitmap-unlock.patch
      ./android-translation-layer-kotatsu-stub.patch
      ./android-translation-layer-mr290.patch
      ./android-translation-layer-fdroid-stub.patch
      ./android-translation-layer-context-stub.patch
      ./android-translation-layer-newpipe-esc-stub.patch
      ./android-translation-layer-newpipe-red-layer.patch
      ./android-translation-layer-wifiinfo-ssid-stub.patch
    ];
  })
