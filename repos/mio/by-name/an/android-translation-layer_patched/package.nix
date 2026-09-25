{
  lib,
  stdenv,
  android-translation-layer,
  art-standalone_patched,
  bionic-translation_patched,
  cacert,
  webp-pixbuf-loader,
  gdk-pixbuf,
  librsvg,
  fetchpatch,
  wrapGAppsHook4,
  vulkan-loader,
  vulkan-headers,
}:

(android-translation-layer.override (
  {
    art-standalone = art-standalone_patched;
    bionic-translation = bionic-translation_patched;
  }
  // lib.optionalAttrs (!stdenv.hostPlatform.isLinux) {
    alsa-lib = null;
    libdrm = null;
    libgudev = null;
    wayland = null;
    wayland-protocols = null;
    wayland-scanner = null;
    libportal-gtk4 = null;
    webkitgtk_6_0 = null;
  }
)).overrideAttrs
  (old: {
    pname = "android-translation-layer-patched";
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      wrapGAppsHook4
    ];
    buildInputs =
      (old.buildInputs or [ ])
      ++ [ webp-pixbuf-loader ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        vulkan-loader
        vulkan-headers
      ];
    patches =
      (old.patches or [ ])
      ++ [
        ./android-translation-layer-bitmap-unlock.patch
        ./android-translation-layer-bitmapfactory-logs.patch
        ./android-translation-layer-kotatsu-stub.patch
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
        ./android-translation-layer-imagebutton-scale.patch
        ./android-translation-layer-view-fullscreen-fix.patch
        ./android-translation-layer-gtk-native-check.patch
        ./android-translation-layer-media-data-source.patch
        ./android-translation-layer-drawlines-bounds.patch
        ./android-translation-layer-concat-2d.patch
        ./android-translation-layer-audiomanager-getdevices.patch
        ./android-translation-layer-networkcapabilities.patch
        ./android-translation-layer-path-op.patch
        ./android-translation-layer-bitmap-pixels-fix.patch
        ./android-translation-layer-bitmap-factory-null-pixbuf.patch
        ./android-translation-layer-bitmap-factory-fd.patch
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
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        ./android-translation-layer-darwin-compat.patch
      ];
    preConfigure =
      (old.preConfigure or "")
      + lib.optionalString stdenv.hostPlatform.isDarwin ''
        cp -r ${./darwin_compat_headers} $NIX_BUILD_TOP/darwin_headers
        chmod -R +w $NIX_BUILD_TOP/darwin_headers
        export CFLAGS="-I$NIX_BUILD_TOP/darwin_headers -Wno-int-conversion -Wno-c23-extensions -Doff64_t=off_t -Dlseek64=lseek -Dftruncate64=ftruncate -Dpread64=pread -Dpwrite64=pwrite -DCLOCK_BOOTTIME=CLOCK_MONOTONIC $CFLAGS"
      '';
    postInstall = (old.postInstall or "") + ''
      mkdir -p $out/etc/security
      ln -s ${cacert.unbundled}/etc/ssl/certs $out/etc/security/cacerts
    '';
    preFixup = (old.preFixup or "") + ''
      mkdir -p $out/lib/gdk-pixbuf-2.0/2.10.0
      GDK_PIXBUF_MODULEDIR=${gdk-pixbuf}/lib/gdk-pixbuf-2.0/2.10.0/loaders ${gdk-pixbuf.dev}/bin/gdk-pixbuf-query-loaders > $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
      cat ${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache >> $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
      GDK_PIXBUF_MODULEDIR=${webp-pixbuf-loader}/lib/gdk-pixbuf-2.0/2.10.0/loaders ${gdk-pixbuf.dev}/bin/gdk-pixbuf-query-loaders >> $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache

      gappsWrapperArgs+=(
        --set ANDROID_ROOT $out
        --set GDK_PIXBUF_MODULE_FILE $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
      )
    '';
    postFixup =
      (old.postFixup or "")
      + lib.optionalString stdenv.hostPlatform.isDarwin ''
        install_name_tool -add_rpath ${art-standalone_patched}/lib $out/bin/.android-translation-layer-wrapped || true
        install_name_tool -add_rpath ${art-standalone_patched}/lib $out/lib/java/dex/android_translation_layer/natives/libtranslation_layer_main.dylib || true
      '';
  })
