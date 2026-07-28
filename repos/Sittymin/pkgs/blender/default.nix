{ pkgs }:

let
  oneapiSupport = pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86_64;

  intelComputeRuntime = pkgs.intel-compute-runtime.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [
      (pkgs.lib.cmakeBool "NEO_BUILD_UNVERSIONED_OCLOC" true)
    ];
  });
in
if oneapiSupport then
  pkgs.blender.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [
      pkgs.intel-llvm
      pkgs.level-zero
      intelComputeRuntime
    ];

    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
      pkgs.addDriverRunpath
      pkgs.intel-graphics-compiler
    ];

    cmakeFlags =
      builtins.filter (f: !pkgs.lib.hasPrefix "-DWITH_CYCLES_DEVICE_ONEAPI" f) oldAttrs.cmakeFlags
      ++ [
        (pkgs.lib.cmakeBool "WITH_CYCLES_DEVICE_ONEAPI" true)
        (pkgs.lib.cmakeFeature "SYCL_ROOT_DIR" "${pkgs.intel-llvm}")
        (pkgs.lib.cmakeFeature "LEVEL_ZERO_ROOT_DIR" "${pkgs.level-zero}")
        (pkgs.lib.cmakeBool "WITH_CYCLES_ONEAPI_BINARIES" true)
        (pkgs.lib.cmakeFeature "OCLOC_INSTALL_DIR" "${intelComputeRuntime}")
        (pkgs.lib.cmakeFeature "IGC_INSTALL_DIR" "${pkgs.intel-graphics-compiler}")
      ];

    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace intern/cycles/kernel/device/oneapi/CMakeLists.txt \
        --replace-fail \
          '${"$"}{cycles_kernel_runtime_lib_target_path})' \
          '"${"$"}{CMAKE_INSTALL_LIBDIR}")'
    '';

    postFixup = (oldAttrs.postFixup or "") + ''
      for f in "$out/bin/blender" "$out/bin/.blender-wrapped" "$out/lib"/libcycles_kernel_oneapi*.so "$out/lib"/libsycl.so; do
        [ -e "$f" ] && addDriverRunpath "$f"
      done
    '';
  })
else
  pkgs.blender
