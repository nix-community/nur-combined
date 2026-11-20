{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  # Vulkan backend (Linux): glslc compiles the shaders at build time; the
  # headers/loader are needed to link and to find the driver at run time.
  shaderc ? null,
  spirv-headers ? null,
  vulkan-headers ? null,
  vulkan-loader ? null,
  src,
  version,
}:

# Lastbook's local-AI runner (packaging/llm/lastbook_llm.cpp): a program that
# speaks JSON lines on stdin/stdout and opens no socket. It is built against
# llama.cpp at the tag upstream's build scripts pin (b12032), because it also
# compiles that tree's common/fit.cpp and needs the same headers/ABI.
let
  llamaCpp = fetchFromGitHub {
    owner = "ggml-org";
    repo = "llama.cpp";
    rev = "dde879bc4f954b809892fd0d660515f42536394a";
    hash = "sha256-6VYDqRNeFWoD3/xep94OWLL+BOn1UYt+B2hDoK5jf6U=";
  };

  isDarwin = stdenv.hostPlatform.isDarwin;

  # Common to both builds: no tools/server/tests, no curl or OpenSSL (nothing
  # in the runner may reach a network), no RPC backend.
  commonFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DLLAMA_BUILD_COMMON=OFF"
    "-DLLAMA_BUILD_TOOLS=OFF"
    "-DLLAMA_BUILD_EXAMPLES=OFF"
    "-DLLAMA_BUILD_TESTS=OFF"
    "-DLLAMA_BUILD_SERVER=OFF"
    "-DLLAMA_CURL=OFF"
    "-DLLAMA_OPENSSL=OFF"
    "-DGGML_RPC=OFF"
    "-DGGML_CCACHE=OFF"
    "-DGGML_NATIVE=OFF"
  ];

  includes = [
    "-I${llamaCpp}/include"
    "-I${llamaCpp}/ggml/include"
    "-I${llamaCpp}/common"
    "-I${llamaCpp}/vendor"
    "-I${llamaCpp}/src"
  ];

  runnerSources = [
    "${src}/packaging/llm/lastbook_llm.cpp"
    "${llamaCpp}/common/fit.cpp"
    "${llamaCpp}/common/log.cpp"
    "${llamaCpp}/common/json.cpp"
  ];
in
stdenv.mkDerivation {
  pname = "lastbook-llm";
  inherit version src;

  nativeBuildInputs = [
    cmake
    ninja
  ]
  ++ lib.optionals (!isDarwin) [ shaderc ];

  buildInputs = lib.optionals (!isDarwin) [
    spirv-headers
    vulkan-headers
    vulkan-loader
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    commonFlags=(
      ${lib.concatStringsSep " " (map lib.escapeShellArg commonFlags)}
    )

    ${lib.optionalString (!isDarwin) ''
      # Linux: shared llama.cpp libraries beside the runner (RUNPATH $ORIGIN),
      # one CPU backend per instruction-set variant so ggml picks the best
      # this processor runs.
      # $ORIGIN as the install RPATH, as upstream does: the libraries are
      # used from beside the runner, and a RUNPATH into the build directory
      # would make Nix's fixup phase reject them.
      cmake -S ${llamaCpp} -B llama-build -G Ninja "''${commonFlags[@]}" \
        -DBUILD_SHARED_LIBS=ON -DGGML_BACKEND_DL=ON -DGGML_CPU_ALL_VARIANTS=ON \
        -DGGML_OPENMP=ON -DGGML_VULKAN=ON \
        -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_INSTALL_RPATH='$ORIGIN' \
        -DCMAKE_SHARED_LINKER_FLAGS='-Wl,--enable-new-dtags' \
        -DCMAKE_MODULE_LINKER_FLAGS='-Wl,--enable-new-dtags'

      # llama plus the Vulkan backend (NVIDIA, AMD, Intel and Arm graphics
      # through their drivers); the CPU variants are separate targets below.
      cmake --build llama-build --target llama ggml-vulkan

      targets=$(ninja -C llama-build -t targets all \
        | sed -n 's/^\(ggml-cpu-[A-Za-z0-9_.-]*\):.*/\1/p' | sort -u)
      [ -n "$targets" ] || targets=ggml-cpu
      for t in $targets; do
        cmake --build llama-build --target "$t"
      done

      $CXX -std=c++17 -O3 -DNDEBUG -pthread \
        ${lib.concatStringsSep " " includes} \
        ${lib.concatStringsSep " " runnerSources} \
        ${src}/packaging/llm/fit_unused_win.cpp \
        -Lllama-build/bin -lllama -lggml -lggml-base \
        -Wl,-rpath,'$ORIGIN' -Wl,--enable-new-dtags -Wl,--as-needed \
        -o lastbook-llm
    ''}

    ${lib.optionalString isDarwin ''
      # macOS (Apple Silicon): llama.cpp's Mac build is static, with Metal and
      # Accelerate BLAS, and everything links into one program.
      cmake -S ${llamaCpp} -B llama-build -G Ninja "''${commonFlags[@]}" \
        -DBUILD_SHARED_LIBS=OFF -DGGML_METAL=ON -DGGML_METAL_EMBED_LIBRARY=ON \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0

      cmake --build llama-build --target llama vendor-hash

      $CXX -std=c++17 -O2 -DNDEBUG -mmacosx-version-min=14.0 \
        ${lib.concatStringsSep " " includes} \
        ${lib.concatStringsSep " " runnerSources} \
        llama-build/src/libllama.a \
        llama-build/ggml/src/libggml.a \
        llama-build/ggml/src/ggml-metal/libggml-metal.a \
        llama-build/ggml/src/ggml-blas/libggml-blas.a \
        llama-build/ggml/src/libggml-cpu.a \
        llama-build/ggml/src/libggml-base.a \
        llama-build/vendor/hash/libvendor-hash.a \
        -framework Metal -framework Foundation -framework MetalKit \
        -framework Accelerate -Wl,-dead_strip \
        -o lastbook-llm
    ''}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/llm
    install -m755 lastbook-llm $out/llm/

    ${lib.optionalString (!isDarwin) ''
      for f in llama-build/bin/libllama.so llama-build/bin/libggml.so llama-build/bin/libggml-base.so; do
        install -m755 -T "$f" "$out/llm/$(objdump -p "$f" | sed -n 's/^ *SONAME *//p')"
      done
      for f in llama-build/bin/libggml-cpu*.so llama-build/bin/libggml-vulkan.so*; do
        [ -e "$f" ] || continue
        install -m755 "$f" $out/llm/
      done
    ''}

    install -m644 ${llamaCpp}/LICENSE $out/llm/LICENSE-llama.cpp.txt

    runHook postInstall
  '';

  meta = {
    description = "Lastbook's pipe-only local AI runner (llama.cpp)";
    homepage = "https://lastbook.org";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ [ "aarch64-darwin" ];
  };
}
