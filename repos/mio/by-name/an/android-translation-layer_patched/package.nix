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
  wrapGAppsHook4,
  vulkan-loader,
  vulkan-headers,
  openxr-loader,
  SDL2,
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
        SDL2
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
        ./android-translation-layer-darwin-runtime.patch
        ./android-translation-layer-darwin-api.patch
      ];
    preConfigure =
      (old.preConfigure or "")
      + lib.optionalString stdenv.hostPlatform.isDarwin ''
        cp -r ${./darwin} src/api-impl-jni/darwin
        chmod -R +w src/api-impl-jni/darwin
        python3 ${./darwin/configure.py}
        cp -r ${./darwin_compat_headers} $NIX_BUILD_TOP/darwin_headers
        chmod -R +w $NIX_BUILD_TOP/darwin_headers
        substituteInPlace src/libandroid/native_window.c \
          --replace-fail '"libopenxr_loader.dylib"' '"${lib.getLib openxr-loader}/lib/libopenxr_loader.dylib"'
        export LDFLAGS="-lobjc -framework AppKit -framework WebKit -framework CoreLocation -framework MediaPlayer -framework UserNotifications -framework QuartzCore $LDFLAGS"
        export CFLAGS="-I$NIX_BUILD_TOP/darwin_headers -Wno-int-conversion -Wno-c23-extensions -Doff64_t=off_t -Dlseek64=lseek -Dftruncate64=ftruncate -Dpread64=pread -Dpwrite64=pwrite -DCLOCK_BOOTTIME=CLOCK_MONOTONIC $CFLAGS"
        export OBJC="$CC"
        export OBJCFLAGS="$CFLAGS -fobjc-arc -fblocks"
        substituteInPlace meson.build \
          --replace-fail "dependency('wayland-protocols', version: '>=1.12')" "dependency('dummy', required: false)" \
          --replace-fail "subdir('protocol')" "wl_proto_headers = []" \
          --replace-fail "wl_proto_sources," "" \
          --replace-fail "dependency('wayland-client')" "dependency('dummy', required: false)" \
          --replace-fail "dependency('libportal')" "dependency('dummy', required: false)" \
          --replace-fail "dependency('libdrm')" "dependency('dummy', required: false)" \
          --replace-fail "dependency('gudev-1.0')" "dependency('dummy', required: false)" \
          --replace-fail "dependency('webkitgtk-6.0')" "dependency('dummy', required: false)" \
          --replace-warn "'-lasound'" "" \
          --replace-warn "'-Wl,-z,lazy'," ""
      '';
    postInstall =
      (old.postInstall or "")
      + ''
        mkdir -p $out/etc/security
        ln -s ${cacert.unbundled}/etc/ssl/certs $out/etc/security/cacerts
      ''
      + lib.optionalString stdenv.hostPlatform.isDarwin ''
        # The loader looks for the boot image at $out/framework/boot.art, but ART cannot
        # write it there at runtime (the store is read-only), so pre-build it here.
        app="$out/Applications/Android Translation Layer.app/Contents"
        mkdir -p "$app/MacOS"
        cp ${./darwin/Info.plist} "$app/Info.plist"
        mv "$out/bin/android-translation-layer" "$app/MacOS/android-translation-layer"
        makeWrapper "$app/MacOS/android-translation-layer" "$out/bin/android-translation-layer"
        mkdir -p $out/framework
        boot_jars=()
        # Keep this order identical to ART's parsed_options.cc default bootclasspath.
        # A glob puts core-oj after its dependents and produces an incompatible image.
        for jar in core-oj apachehttp apache-xml bouncycastle core-junit core-libart \
          hamcrest junit-runner okhttp wolfssljni; do
          j=${art-standalone_patched}/lib/java/dex/art/$jar-hostdex.jar
          test -f "$j"
          boot_jars+=(--dex-file="$j" --dex-location="$j")
        done
        ${art-standalone_patched}/bin/dex2oat \
          --image=$out/framework/boot.art \
          "''${boot_jars[@]}" \
          --oat-file=$out/framework/boot.oat \
          --instruction-set=${if stdenv.hostPlatform.isAarch64 then "arm64" else "x86_64"} \
          ${lib.optionalString stdenv.hostPlatform.isAarch64 "--instruction-set-features=-a53,crc,-lse,fp16,dotprod"} \
          --base=${if stdenv.hostPlatform.isAarch64 then "0x300000000" else "0x70000000"} --host
      '';
    doCheck = stdenv.hostPlatform.isDarwin || (old.doCheck or false);
    checkPhase =
      if stdenv.hostPlatform.isDarwin then
        ''
          runHook preCheck
          meson test --no-rebuild --print-errorlogs darwin-audio
          runHook postCheck
        ''
      else
        (old.checkPhase or "");
    preFixup =
      (old.preFixup or "")
      + lib.optionalString stdenv.hostPlatform.isDarwin ''
        for binary in \
          "$out/Applications/Android Translation Layer.app/Contents/MacOS/android-translation-layer" \
          $out/lib/java/dex/android_translation_layer/natives/libtranslation_layer_main.dylib; do
          install_name_tool -add_rpath ${art-standalone_patched}/lib/art "$binary"
          install_name_tool -add_rpath ${art-standalone_patched}/lib "$binary"
        done
      ''
      + ''
        mkdir -p $out/lib/gdk-pixbuf-2.0/2.10.0
        GDK_PIXBUF_MODULEDIR=${gdk-pixbuf}/lib/gdk-pixbuf-2.0/2.10.0/loaders ${gdk-pixbuf.dev}/bin/gdk-pixbuf-query-loaders > $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
        cat ${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache >> $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
        GDK_PIXBUF_MODULEDIR=${webp-pixbuf-loader}/lib/gdk-pixbuf-2.0/2.10.0/loaders ${gdk-pixbuf.dev}/bin/gdk-pixbuf-query-loaders >> $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache

        gappsWrapperArgs+=(
          --set ANDROID_ROOT $out
          --set GDK_PIXBUF_MODULE_FILE $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
        )
      '';
  })
