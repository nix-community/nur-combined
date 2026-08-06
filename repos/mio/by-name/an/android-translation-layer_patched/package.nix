{
  android-translation-layer,
  art-standalone_patched,
  cacert,
  fetchpatch,
}:

(android-translation-layer.override {
  art-standalone = art-standalone_patched;
}).overrideAttrs
  (old: {
    patches = (old.patches or [ ]) ++ [
      ./android-translation-layer-bitmap-unlock.patch
      ./android-translation-layer-kotatsu-stub.patch
      (fetchpatch {
        url = "https://gitlab.com/android_translation_layer/android_translation_layer/-/merge_requests/290.patch";
        hash = "sha256-pDN/2s6k4T4A1EGqIhFZGTH/PwvmsDJAr0BBQmFpxG0=";
      })
      ./android-translation-layer-fdroid-stub.patch
      ./android-translation-layer-context-stub.patch
      ./android-translation-layer-newpipe-esc-stub.patch
      ./android-translation-layer-newpipe-red-layer.patch
      ./android-translation-layer-wifiinfo-ssid-stub.patch
    ];
    postInstall = (old.postInstall or "") + ''
      mkdir -p $out/etc/security
      ln -s ${cacert.unbundled}/etc/ssl/certs $out/etc/security/cacerts
    '';
    postFixup = (old.postFixup or "") + ''
      wrapProgram $out/bin/android-translation-layer \
        --set ANDROID_ROOT $out
    '';
  })
