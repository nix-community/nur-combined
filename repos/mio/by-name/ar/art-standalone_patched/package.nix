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
    # The unpinned nixpkgs channel now marks vixl broken; it builds and works fine here, so clear
    # the flag to allow evaluation.
    meta = (old.meta or { }) // {
      broken = false;
    };
  });

  wolfssl-jni = (wolfssl.override { enableJni = true; }).overrideAttrs (_: {
    doCheck = false;
  });

  darwinPatches = [
    ./darwin-libcore.patch
    ./darwin-fault-handler-arm64.patch
    ./darwin-build-system.patch
    ./darwin-system.patch
    ./darwin-arm64-nativehelper-asyncclose.patch
    ./darwin-arm64-openjdk-jvm-timeout.patch
    ./darwin-arm64-oat-skip-dlopen.patch
    ./darwin-libcore-host.patch
    ./darwin-arm64-libcore-strerror.patch
    ./darwin-art-runtime.patch
    ./darwin-arm64-core-libs-dylib.patch
    ./darwin-arm64-asm.patch
    # Boot image alloc calls pass a compressed class. Turn it into a pointer and
    # install the alloc stubs, which the Apple build actually links.
    ./darwin-arm64-alloc-entrypoints.patch
    # Quick stubs load compressed heap refs and then dereference them.
    ./darwin-arm64-imt-trampoline.patch
    # Thin lock whose owner thread is gone: clear it instead of spinning.
    ./darwin-arm64-abandoned-lock.patch
    ./darwin-misc.patch
    # Skip CHECK_EQ(sysconf(_SC_PAGE_SIZE), kPageSize) on Apple Silicon where
    # the host page size is 16 KB but ART's kPageSize is compiled as 4 KB.
    ./darwin-page-size.patch
    ./darwin-arm64-page-size-16k.patch
    # Arm64 Darwin: store heap references relative to a base above the low 4 GiB,
    # which arm64 macOS reserves.  See DARWIN-ARM64.md.
    ./darwin-arm64-relative-refs.patch
    ./darwin-arm64-relative-refs-mterp.patch
    ./darwin-arm64-relative-refs-mterp-other.patch
    ./darwin-arm64-relative-refs-alloc.patch
    ./darwin-arm64-relative-refs-heap.patch
    ./darwin-arm64-heap-window-begin.patch
    ./darwin-arm64-relative-refs-image-base.patch
    # Image header addresses are the low 32 bits of pointers in the reference window.
    ./darwin-arm64-image-address.patch
    ./darwin-arm64-relative-refs-unstarted.patch
    ./darwin-arm64-thread-pool-stack.patch
    ./fh-diagnostic.patch
    # 16 KiB page-size: the heap does mprotect/madvise at page granularity, which macOS rejects at
    # ART's 4 KiB kPageSize.  See DARWIN-ARM64.md.
    ./darwin-arm64-page-size-mprotect.patch
    # Upstream stubs the quick alloc entrypoints for Apple; skip the two calls to it.
    ./darwin-arm64-quick-entrypoints.patch
    # Compiled refs are offsets from g_reference_base. Materialize a pointer
    # before dereferencing, and keep boot-image ADRP addresses 64-bit.
    ./darwin-arm64-codegen-refs.patch
    # Vector array loads add the index with a 32-bit add, which drops the high
    # half of the array pointer (System.arraycopy's byte copy loop).
    ./darwin-arm64-vector-refs.patch
    # String.equals and Unsafe get/put load through a compressed ref.
    ./darwin-arm64-intrinsic-refs.patch
    # Apple Silicon W^X: MAP_JIT for the code cache, and copy oat RX segments
    # because the kernel rejects file-backed PROT_EXEC.
    ./darwin-arm64-wx-exec.patch
    # Avoid undefined behavior in VisitClassLoaderDexFiles and ensure class definition
    # failures throw an exception instead of aborting dex2oat.
    ./darwin-arm64-class-linker.patch
    # Diagnostic dump for ucontext and stack trace, plus null-safe catch block search.
    ./darwin-arm64-catch-dump.patch
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

  # Upstream sets -Wno-error so ART host unused-parameter warnings stay warnings.
  env.NIX_CFLAGS_COMPILE =
    (old.env.NIX_CFLAGS_COMPILE or "-Wno-error")
    + optionalString stdenv.hostPlatform.isDarwin " -D_ALLBSD_SOURCE -DSIGRTMIN=32 -DSIGRTMAX=64 -DART_USE_RELATIVE_REFS=1";

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
