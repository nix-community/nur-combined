{
  lib,
  autoAddDriverRunpath ? null,
  cmake,
  fetchFromGitHub,
  installShellFiles,
  stdenv,

  rocmSupport ? !stdenv.hostPlatform.isDarwin,
  rocmPackages ? { },
  # 6900 XT (RDNA2) by default; override per-machine, e.g. the 9060 XT (RDNA4)
  # needs its own target - confirm with `rocminfo | grep gfx` on that box
  # rather than trusting a guess here.
  rocmGpuTargets ? [ "gfx1030" ],

  metalSupport ? stdenv.hostPlatform.isDarwin,

  fetchNpmDeps,
  nodejs_latest,
  npmHooks,

  pkg-config,
  openssl,
  ninja,
}:

assert rocmSupport -> !stdenv.hostPlatform.isDarwin;
assert metalSupport -> stdenv.hostPlatform.isDarwin;

stdenv.mkDerivation (finalAttrs: {
  pname = "llama-cpp-prism";
  # Tracks the `prism` branch HEAD, not a stable release - bump `rev` by hand
  # (`git ls-remote https://github.com/PrismML-Eng/llama.cpp.git prism`) and
  # update `hash` from the fetcher's mismatch error.
  version = "unstable-2026-07-15";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "PrismML-Eng";
    repo = "llama.cpp";
    rev = "62061f91088281e65071cc38c5f69ee95c39f14e";
    hash = "sha256-zLxB5UKnCTCw/okB+L8u1VtM1o2yVjVYTlTBgL/BsaM=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse --short HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  nativeBuildInputs = [
    cmake
    installShellFiles
    ninja
    nodejs_latest
    npmHooks.npmConfigHook
    pkg-config
  ]
  ++ lib.optionals rocmSupport [
    autoAddDriverRunpath
    rocmPackages.clr
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals rocmSupport [
    rocmPackages.clr
    rocmPackages.hipblas
    rocmPackages.rocblas
  ];

  npmRoot = "tools/ui";
  npmDepsHash = "sha256-pjdbI6NcZRlJVd62xhgbLhWrwFYwgsIwjORqvo1+VD8=";
  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src patches;
    preBuild = ''
      pushd ${finalAttrs.npmRoot}
    '';
    hash = finalAttrs.npmDepsHash;
  };

  patches = [ ];

  preConfigure = ''
    prependToVar cmakeFlags "-DLLAMA_BUILD_COMMIT:STRING=$(cat COMMIT)"
    pushd ${finalAttrs.npmRoot}
    npm run build
    popd
  '';

  cmakeFlags = [
    (lib.cmakeBool "GGML_NATIVE" false)
    (lib.cmakeBool "LLAMA_BUILD_EXAMPLES" false)
    (lib.cmakeBool "LLAMA_BUILD_SERVER" true)
    (lib.cmakeBool "LLAMA_BUILD_TESTS" false)
    (lib.cmakeBool "LLAMA_OPENSSL" true)
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "GGML_HIP" rocmSupport)
    (lib.cmakeBool "GGML_METAL" metalSupport)
  ]
  ++ lib.optionals rocmSupport [
    (lib.cmakeFeature "CMAKE_HIP_COMPILER" "${rocmPackages.clr.hipClangPath}/clang++")
    (lib.cmakeFeature "CMAKE_HIP_ARCHITECTURES" (builtins.concatStringsSep ";" rocmGpuTargets))
  ]
  ++ lib.optionals metalSupport [
    (lib.cmakeFeature "CMAKE_C_FLAGS" "-D__ARM_FEATURE_DOTPROD=1")
    (lib.cmakeBool "LLAMA_METAL_EMBED_LIBRARY" true)
  ];

  postInstall = ''
    mkdir -p $out/include
    cp $src/include/llama.h $out/include/
  '';

  doCheck = false;

  meta = {
    description = "PrismML fork of llama.cpp with Bonsai hybrid-attention/ternary kernels, ROCm build";
    homepage = "https://github.com/PrismML-Eng/llama.cpp";
    license = lib.licenses.mit;
    mainProgram = "llama-cli";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
