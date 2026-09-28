{
  art-standalone,
  lib,
  stdenv,
  bionic-translation_patched,
  vixl,
  wolfssl,
  libcap,
  ...
}:

let
  inherit (lib)
    elem
    filter
    getName
    optionalString
    optionals
    ;

  removedBuildInputs = [
    "libcap"
    "bionic-translation"
  ];

  filterBuildInputs =
    drv:
    let
      name = getName drv;
    in
    !(elem name removedBuildInputs);

  vixl_patched = vixl.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./vixl-compiler-fixes.patch ];
  });

  wolfssl-jni = (wolfssl.override { enableJni = true; }).overrideAttrs (_: {
    doCheck = false;
  });

  darwinPatches = [
    ./darwin-libcore.patch
    ./darwin-fault-handler-arm64.patch
    ./darwin-build-system.patch
    ./darwin-system.patch
    ./darwin-libcore-host.patch
    ./darwin-art-runtime.patch
    ./darwin-arm64-asm.patch
    ./darwin-misc.patch
    # Skip CHECK_EQ(sysconf(_SC_PAGE_SIZE), kPageSize) on Apple Silicon where
    # the host page size is 16 KB but ART's kPageSize is compiled as 4 KB.
    ./darwin-page-size.patch
  ];

  darwinPostPatch = ''
        substituteInPlace art/build/Android.common_build.mk \
          --replace-fail '@VIXL_INCLUDE@' '${vixl_patched}/include/vixl'
        bash ${./darwin-setup-host.sh}
        
        # Fix uninitialized pthread_cond_t in dex2oat's WatchDog on macOS
        sed -i -e '/#ifndef __APPLE__/,/#endif/c\
    #ifndef __APPLE__\
        pthread_condattr_t condattr;\
        CHECK_WATCH_DOG_PTHREAD_CALL(pthread_condattr_init, (&condattr), reason);\
        CHECK_WATCH_DOG_PTHREAD_CALL(pthread_condattr_setclock, (&condattr, CLOCK_MONOTONIC), reason);\
        CHECK_WATCH_DOG_PTHREAD_CALL(pthread_cond_init, (&cond_, &condattr), reason);\
        CHECK_WATCH_DOG_PTHREAD_CALL(pthread_condattr_destroy, (&condattr), reason);\
    #else\
        CHECK_WATCH_DOG_PTHREAD_CALL(pthread_cond_init, (&cond_, nullptr), reason);\
    #endif
    ' art/dex2oat/dex2oat.cc
  '';

  darwinHostBins = [
    "dalvikvm"
    "dex2oat"
  ];

in
art-standalone.overrideAttrs (old: {
  pname = "art-standalone-patched";

  env.NIX_CFLAGS_COMPILE = optionalString stdenv.hostPlatform.isDarwin "-D_ALLBSD_SOURCE -DSIGRTMIN=32 -DSIGRTMAX=64";

  patches =
    filter (p: baseNameOf (toString p) != "remove-wolfssljni.patch") (old.patches or [ ])
    ++ [
      ./dx-workaround.patch
      ./art-datetime-formatter-lambda-crash.patch
      ./dex2oat-path.patch
      ./wolfssljni-freed-session-timeout.patch
    ]
    ++ optionals stdenv.hostPlatform.isDarwin darwinPatches;

  buildInputs =
    filter filterBuildInputs (old.buildInputs or [ ])
    ++ optionals stdenv.hostPlatform.isLinux [ libcap ]
    ++ [
      bionic-translation_patched
      wolfssl-jni
      vixl_patched
    ];

  postPatch = (old.postPatch or "") + optionalString stdenv.hostPlatform.isDarwin darwinPostPatch;

  postInstall =
    (old.postInstall or "")
    + optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p "$out/lib64"
      for f in "$out"/lib/art/* "$out"/lib/java/dex/art/natives/*; do
        [ -e "$f" ] || continue
        ln -sfn "$f" "$out/lib64/$(basename "$f")"
      done
    '';

  postFixup =
    (old.postFixup or "")
    + optionalString stdenv.hostPlatform.isDarwin ''
      # libutils omits libcutils/liblog (circular Android.mk dep); preload for dyld.
      for bin in ${lib.concatStringsSep " " darwinHostBins}; do
        if [ -x "$out/bin/$bin" ]; then
          wrapProgram "$out/bin/$bin" \
            --prefix DYLD_LIBRARY_PATH : "$out/lib" \
            --prefix DYLD_LIBRARY_PATH : "$out/lib/art" \
            --prefix DYLD_LIBRARY_PATH : "$out/lib/java/dex/art/natives" \
            --prefix DYLD_INSERT_LIBRARIES : "$out/lib/libcutils.dylib" \
            --prefix DYLD_INSERT_LIBRARIES : "$out/lib/liblog.dylib"
        fi
      done
    '';

  meta = (old.meta or { }) // {
    description = "Android Runtime standalone with Linux and Darwin host support";
    mainProgram = "dalvikvm";
    platforms = with lib.platforms; linux ++ darwin;
  };
})
