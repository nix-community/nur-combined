# revert
# https://github.com/NixOS/nixpkgs/pull/367104
# v8: drop
#
# > Depending packages were previously already migrated to nodejs.libv8
#
# nodejs.libv8 does not work in my case
# linking libv8.a fails with
# relocation R_X86_64_TPOFF32 against hidden symbol `_ZN2v88internal18g_current_isolate_E'
# can not be used when making a shared object
#
# so apparently building an actual libv8_monolith.a
# is more complex than
# $AR -cqs $libv8/lib/libv8.a @files
# in
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/web/nodejs/nodejs.nix



# example override:
/*
  v8.overrideAttrs (oldAttrs: {
    pname = "libmini_racer";
    postUnpack = (oldAttrs.postUnpack or "") + ''
      ln -v -s ${finalAttrs.src}/src/v8_py_frontend $sourceRoot/custom_deps/mini_racer
    '';
    gnFlags = (oldAttrs.gnFlags or [ ]) ++ [
      ''v8_custom_deps="//custom_deps/mini_racer"''
    ];
    installPhase = ''
      cp -v libmini_racer.so $out/lib
    '';
  });
*/

{
  lib,
  stdenv,
  gclient2nix,
  gn,
  ninja,
  python3,
  pkg-config,
  glib,
  icu,
  llvmPackages,

  mmv,

  rustc,
  cargo,
  rust-bindgen,

  # NOTE this cannot be in attributes
  # error: cannot coerce a set to a string: { }
  # TODO? convert to list of key-value strings like gnFlags
  # v8_custom_deps ? { },

  # build libv8.so etc instead of libv8_monolith.a
  # useful for debugging
  enableShared ? false,
}:

llvmPackages.libcxxStdenv.mkDerivation rec {

  pname = "v8";
  version = (builtins.fromJSON (builtins.readFile ./info.json)).src.args.tag;

  inherit enableShared;

  gclientDeps = gclient2nix.importGclientDeps ./info.json;

  sourceRoot = "src";

  nativeBuildInputs = [
    gclient2nix.gclientUnpackHook
    gn
    ninja
    python3
    pkg-config
    mmv

    # fix: clang++: error: invalid linker name in argument '-fuse-ld=lld'
    llvmPackages.bintools-unwrapped

    # todo remove? already in llvmPackages.libcxxStdenv
    llvmPackages.clang

    # libclang_rt.builtins.a
    llvmPackages.compiler-rt
  ];

  buildInputs = [
    glib
    icu
  ];

  /*
  postUnpack = ''
    ${builtins.concatStringsSep "\n" (
      builtins.attrValues
      (builtins.mapAttrs
      (n: p: ''ln -v -s ${p} $sourceRoot/custom_deps/${n}'')
      v8_custom_deps)
    )}
  '';
  */

  # --- patches / fixes (minimal for V8) ---
  postPatch = ''
    # Avoid LASTCHANGE dependency
    echo "0" > build/util/LASTCHANGE.committime

    # Avoid gclient args dependency
    mkdir -p build/config
    echo "" > build/config/gclient_args.gni

    # fix:
    # ERROR at //build/config/compiler/BUILD.gn:1778:15: Could not read file.
    #               "//third_party/llvm-build/Release+Asserts/cr_build_revision",
    #               ^-----------------------------------------------------------
    # I resolved this to "/build/src/third_party/llvm-build/Release+Asserts/cr_build_revision".
    # See //BUILD.gn:888:5: which caused the file to be included.
    #     "//build/config/compiler:wexit_time_destructors",
    #     ^-----------------------------------------------
    substituteInPlace BUILD.gn \
      --replace 'import("//build/config/clang/clang.gni")' ""

    # fix: ninja: error: '.../lib/clang/23/lib/x86_64-unknown-linux-gnu/libclang_rt.builtins.a',
    # needed by 'obj/libv8_libbase.a', missing and no known rule to make it
    substituteInPlace tools/clang/scripts/package.py \
      --replace \
        "libclang_rt.builtins.a" \
        "libclang_rt.builtins-x86_64.a"

    # mock file paths for the v8 builder
    mkdir -p $TMP/clang/lib/clang/23/lib/x86_64-unknown-linux-gnu
    ln -v -s ${llvmPackages.compiler-rt}/lib/linux/libclang_rt.builtins-x86_64.a \
      $TMP/clang/lib/clang/23/lib/x86_64-unknown-linux-gnu/libclang_rt.builtins.a
    mkdir -p $TMP/clang/bin
    # bin/clang
    ln -v -s ${llvmPackages.stdenv.cc}/bin/* $TMP/clang/bin
    # bin/llvm-ar
    ln -v -s ${llvmPackages.libllvm}/bin/* $TMP/clang/bin
    # bin/ld
    ln -v -s ${llvmPackages.bintools}/bin/* $TMP/clang/bin || true
    ln -v -s ${llvmPackages.stdenv.cc}/resource-root $TMP/clang
    mkdir -p $TMP/clang/share
    mkdir -p $TMP/clang/lib/clang/23/share
    ln -v -s ${llvmPackages.libcxx}/share/libc++ $TMP/clang/share
    # ln -v -s ${llvmPackages.libcxx}/share/libc++ $TMP/clang/lib/clang/23/share
    ln -v -s ${llvmPackages.libcxx}/lib/* $TMP/clang/lib
    # ln -v -s ${llvmPackages.libcxx}/lib/* $TMP/clang/lib/clang/23/lib/x86_64-unknown-linux-gnu
    gnFlagsArray+=(
      "clang_base_path=\"$TMP/clang\""
    )
    # fix clang
    substituteInPlace build/config/compiler/BUILD.gn \
      --replace \
        'cflags += [ "-fno-lifetime-dse" ]' \
        '# cflags += [ "-fno-lifetime-dse" ]' \
      --replace \
        '"-fsanitize-ignore-for-ubsan-feature=array-bounds",' \
        '# "-fsanitize-ignore-for-ubsan-feature=array-bounds",' \
      --replace \
        '"-Wno-unsafe-buffer-usage-in-static-sized-array",' \
        '# "-Wno-unsafe-buffer-usage-in-static-sized-array",'
  '';

  # --- GN configuration ---
  # https://github.com/bpcreech/PyMiniRacer/blob/95b89887e74103a91747bca45a1e35ff0e1b81c3/builder/v8_build.py#L227
  gnFlags = [
    /*
    "is_debug=false"

    # From https://groups.google.com/g/v8-users/c/qDJ_XYpig_M/m/qe5XO9PZAwAJ:
    # V8 monolithic static library will be linked into another shared library.
    "v8_monolithic_for_shared_library=true"

    # "target_cpu": f'"{target_cpu}"',
    # "v8_target_cpu": f'"{target_cpu}"',

    # "v8_enable_i18n_support=true" # TODO?

    "use_dummy_lastchange=true"
    "is_clang=true"
    "treat_warnings_as_errors=false"
    "fatal_linker_warnings=false"
    "symbol_level=0"
    "enable_profiling=false"
    */

    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/li/livekit-libwebrtc/package.nix
    "use_sysroot=false"

    # fix: ninja: error: '../../third_party/rust-toolchain/bin/bindgen',
    # needed by 'gen/build/rust/allocator/alloc_error_handler_impl_ffi_generator/bindings.rs',
    # missing and no known rule to make it
    "enable_rust=false"

    # temporal requires rust
    "v8_enable_temporal_support=false"

    # fix:
    # error: unable to find plugin 'find-bad-constructs'
    # error: unable to find plugin 'raw-ptr-plugin'
    "clang_use_chrome_plugins=false"

    # TODO more?
  ]
  ++ (if enableShared then [
    # "is_debug=true"
    # shared library: libv8.so = debug build, slow
    "is_component_build=true"
  ] else [
    # "is_debug=false"
    # static library: libv8.a
    "v8_monolithic=true"
    "is_component_build=false"
    "v8_use_external_startup_data=false"
  ])
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    # "is_clang=false"
  ]
  # ++ (if v8_custom_deps == { } then [ ] else [
  #   ("v8_custom_deps=" + (builtins.concatStringsSep "," (builtins.attrValues (builtins.mapAttrs (n: p: ''"//custom_deps/${n}"'') v8_custom_deps))))
  # ])
  ;

  # -Wp,-w
  # disable preprocessor warnings like
  # <command-line>: warning: ‘_LIBCPP_HARDENING_MODE’ redefined
  # <command-line>: note: this is the location of the previous definition

  env.NIX_CFLAGS_COMPILE = "-Wno-unused-variable -Wp,-w";

    # # fix: ERROR at //build/config/chrome_build.gni:5:1: Unable to load "/build/src/build/config/gclient_args.gni".
    # echo "generate_location_tags = true" >> build/config/gclient_args.gni

  preConfigure = ''
    # fix: configure can silently fail
    set -x
  '';

  postConfigure = ''
    set +x
  '';

  # fix: no targets are built by default
  buildPhase = ''
    TERM=dumb \
    ninja
  '';

  # fix: no targets are installed by default
  # TODO create a pkgconfig file for v8
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/web/nodejs/nodejs.nix
  installPhase = ''
    runHook preInstall

    # install libraries
    mkdir -p $out/lib
    if [ $enableShared = 0 ]; then
      cp -v obj/libv8_monolith.a $out/lib
      # libwee8: smaller V8 variant (used for embedded/minimal builds)
      cp -v obj/libwee8.a $out/lib
    else
      cp -v *.so $out/lib
    fi

    # install headers
    cp -v -r ../../include $out
    cp -v -r gen/include/* $out/include

    runHook postInstall
  '';

  meta = with lib; {
    description = "V8 JavaScript engine";
    homepage = "https://v8.dev";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
