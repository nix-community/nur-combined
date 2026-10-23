# Runtime for the omnivoice-gguf engine. `rev` must match _meta.runtime_commit_sha
# in backend/engines/omnivoice_gguf/quant_map.json (checked by voice-studio).
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  blas,
}:
let
  # Pick the best CPU variant at runtime instead of -march=native.
  cpuVariants = stdenv.hostPlatform.isx86_64;
  sharedLibrary = stdenv.hostPlatform.extensions.sharedLibrary;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "omnivoice-cpp";
  version = "0-unstable-2026-05-17";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "ServeurpersoCom";
    repo = "omnivoice.cpp";
    rev = "886fc079838ca7400cb2b42b36e2a65aa1daabe8";
    # ggml fork
    fetchSubmodules = true;
    hash = "sha256-8PSwpMAnqXXt5P9iRhO+alvndeu5aunGKMokkZYdGyw=";
  };

  # The version banner is read from git.
  postPatch = ''
    substituteInPlace tools/version.cmake \
      --replace-fail 'set(GIT_HASH "unknown")' 'set(GIT_HASH "${
        builtins.substring 0 7 finalAttrs.src.rev
      }")' \
      --replace-fail 'set(GIT_DATE "unknown")' 'set(GIT_DATE "${lib.removePrefix "0-unstable-" finalAttrs.version}")'
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [ blas ];

  cmakeFlags = [
    (lib.cmakeBool "GGML_NATIVE" false)
    (lib.cmakeBool "GGML_BLAS" true)
    (lib.cmakeBool "GGML_BACKEND_DL" cpuVariants)
    (lib.cmakeBool "GGML_CPU_ALL_VARIANTS" cpuVariants)
    # Backends are loaded from the executable's directory.
    (lib.cmakeBool "CMAKE_BUILD_WITH_INSTALL_RPATH" true)
    (lib.cmakeFeature "CMAKE_INSTALL_RPATH" (
      if stdenv.hostPlatform.isDarwin then "@loader_path" else "$ORIGIN"
    ))
  ];

  # No install rules upstream.
  installPhase = ''
    runHook preInstall

    libexec=$out/libexec/omnivoice-cpp
    install -Dm755 -t $libexec omnivoice-tts omnivoice-codec quantize
    find . -maxdepth 1 -name '*${sharedLibrary}*' -exec cp -P -t $libexec {} +

    mkdir -p $out/bin
    for exe in omnivoice-tts omnivoice-codec; do
      ln -s $libexec/$exe $out/bin/$exe
    done
    ln -s $libexec/quantize $out/bin/omnivoice-quantize

    runHook postInstall
  '';

  meta = {
    description = "OmniVoice text-to-speech inference in C++ with ggml";
    homepage = "https://github.com/ServeurpersoCom/omnivoice.cpp";
    license = lib.licenses.mit;
    mainProgram = "omnivoice-tts";
    maintainers = [ lib.maintainers.skyesoss ];
    platforms = lib.platforms.unix;
  };
})
