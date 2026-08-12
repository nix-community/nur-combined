{
  android-translation-layer,
  art-standalone_patched,
  cacert,
  webp-pixbuf-loader,
  gdk-pixbuf,
  librsvg,
  fetchpatch,
  wrapGAppsHook4,
}:

(android-translation-layer.override {
  art-standalone = art-standalone_patched;
}).overrideAttrs
  (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      wrapGAppsHook4
    ];
    buildInputs = (old.buildInputs or [ ]) ++ [
      webp-pixbuf-loader
    ];
    patches = (old.patches or [ ]) ++ [
      ./android-translation-layer-bitmap-unlock.patch
      ./android-translation-layer-debug.patch
      ./android-translation-layer-kotatsu-stub.patch
      (fetchpatch {
        url = "https://gitlab.com/android_translation_layer/android_translation_layer/-/merge_requests/290.patch";
        hash = "sha256-pDN/2s6k4T4A1EGqIhFZGTH/PwvmsDJAr0BBQmFpxG0=";
      })
      (fetchpatch {
        url = "https://gitlab.com/android_translation_layer/android_translation_layer/-/merge_requests/251.patch";
        hash = "sha256-c0Vsly+ScZmhrsRl7tKGIY4wLlIkR6UaGANIYWosF4k=";
      })
      ./android-translation-layer-fdroid-stub.patch
      ./android-translation-layer-context-stub.patch
      ./android-translation-layer-newpipe-esc-stub.patch
      ./android-translation-layer-newpipe-red-layer.patch
      ./android-translation-layer-wifiinfo-ssid-stub.patch
      ./android-translation-layer-apk-sourcedir.patch
      ./android-translation-layer-wifi-ap-stub.patch
      ./android-translation-layer-system-app-certs.patch
      ./android-translation-layer-gtk-measure.patch
      ./android-translation-layer-wrapper-measure-fix.patch
      ./android-translation-layer-view-fullscreen-fix.patch
      ./android-translation-layer-gtk-native-check.patch
      ./android-translation-layer-media-data-source.patch
      ./android-translation-layer-drawlines-bounds.patch
      ./android-translation-layer-concat-2d.patch
      ./android-translation-layer-display-getmode.patch
      ./android-translation-layer-audiomanager-getdevices.patch
      ./android-translation-layer-bitmap-pixels-fix.patch
      ./android-translation-layer-bitmap-factory-null-pixbuf.patch
      ./android-translation-layer-bitmap-factory-fd.patch
      ./android-translation-layer-env-test.patch
      ./android-translation-layer-color-state-list-magenta.patch
      ./android-translation-layer-paint-color-filter-matrix.patch
      ./android-translation-layer-cairo-fallback.patch
      ./android-translation-layer-mr248-ads-stubs.patch
      ./android-translation-layer-microg-poc.patch
      ./android-translation-layer-gms-startservice-poc.patch
      ./android-translation-layer-gms-availability-stub.patch
      ./android-translation-layer-firebase-stubs.patch
      ./android-translation-layer-gms-client-stubs.patch
      ./android-translation-layer-gms-tasks-stubs.patch
      ./android-translation-layer-gms-location-stubs.patch
    ];
    postInstall = (old.postInstall or "") + ''
      mkdir -p $out/etc/security
      ln -s ${cacert.unbundled}/etc/ssl/certs $out/etc/security/cacerts
    '';
    preFixup = (old.preFixup or "") + ''
      mkdir -p $out/lib/gdk-pixbuf-2.0/2.10.0
      cat ${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache > $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
      GDK_PIXBUF_MODULEDIR=${webp-pixbuf-loader}/lib/gdk-pixbuf-2.0/2.10.0/loaders ${gdk-pixbuf.dev}/bin/gdk-pixbuf-query-loaders >> $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache

      gappsWrapperArgs+=(
        --set ANDROID_ROOT $out
        --set GDK_PIXBUF_MODULE_FILE $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
      )
    '';
    postFixup = (old.postFixup or "") + "";
  })
