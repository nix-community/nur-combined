{
  stdenv,
  lib,
  fetchFromGitHub,
  python3,
  customtkinter,

  config,
  cudaSupport ? config.cudaSupport,
  cudaPackages ? { },

  openclSupport ? !cudaSupport,
  clblast,
  ocl-icd,

  blasSupport ? !cudaSupport,
  openblas,

  vulkanSupport ? !cudaSupport,
  vulkan-loader,

  nix-update-script,
}:
let
  # It's necessary to consistently use backendStdenv when building with CUDA support,
  # otherwise we get libstdc++ errors downstream.
  # cuda imposes an upper bound on the gcc version, e.g. the latest gcc compatible with cudaPackages_11 is gcc11
  effectiveStdenv = if cudaSupport then cudaPackages.backendStdenv else stdenv;

  pname = "koboldcpp";
  version = "1.63";

  src = fetchFromGitHub {
    owner = "LostRuins";
    repo = "koboldcpp";
    rev = "v${version}";
    hash = "sha256-LAAINN49gjJPye3rfbA8oh29/qcVVk99SSRZD8WQNKQ=";
  };

  koboldcpp-libs = effectiveStdenv.mkDerivation {
    pname = "${pname}-libs";
    inherit version src;

    enableParallelBuilding = true;

    nativeBuildInputs = lib.optionals cudaSupport [
      cudaPackages.cuda_nvcc
      cudaPackages.autoAddDriverRunpath
    ];

    buildInputs =
      lib.optionals cudaSupport (
        with cudaPackages;
        [
          cuda_cccl.dev # <nv/target>
          # A temporary hack for reducing the closure size, remove once cudaPackages
          # have stopped using lndir: https://github.com/NixOS/nixpkgs/issues/271792
          cuda_cudart.dev
          cuda_cudart.lib
          cuda_cudart.static
          libcublas.dev
          libcublas.lib
          libcublas.static
        ]
      )
      ++ lib.optionals openclSupport [
        openblas
        clblast
        ocl-icd
      ]
      ++ lib.optionals blasSupport [ openblas ]
      ++ lib.optionals vulkanSupport [ vulkan-loader ];

    makeFlags =
      [ "LLAMA_PORTABLE=1" ]
      ++ lib.optionals cudaSupport [ "LLAMA_CUBLAS=1" ]
      ++ lib.optionals openclSupport [ "LLAMA_CLBLAST=1" ]
      ++ lib.optionals blasSupport [ "LLAMA_OPENBLAS=1" ]
      ++ lib.optionals vulkanSupport [ "LLAMA_VULKAN=1" ];

    preBuild = lib.optionalString cudaSupport ''
      substituteInPlace Makefile \
        --replace "-lcuda " "-lcuda -L${cudaPackages.cuda_cudart.lib}/lib/stubs "
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      cp *.so $out/lib

      runHook postInstall
    '';
  };
in
effectiveStdenv.mkDerivation {
  inherit pname version src;

  propagatedBuildInputs = [
    (python3.withPackages (
      ps: [
        ps.numpy
        ps.sentencepiece
        ps.tkinter
        customtkinter
      ]
    ))
  ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/{bin,lib}
    install -m755 ./koboldcpp.py $out/bin/koboldcpp
    cp ./{klite.embd,kcpp_docs.embd,rwkv_vocab.embd,rwkv_world_vocab.embd} $out/lib
    cp ${koboldcpp-libs}/lib/*.so $out/lib

    substituteInPlace $out/bin/koboldcpp \
      --replace "koboldcpp_default.so" "$out/lib/koboldcpp_default.so" \
      --replace "koboldcpp_failsafe.so" "$out/lib/koboldcpp_failsafe.so" \
      --replace "koboldcpp_openblas.so" "$out/lib/koboldcpp_openblas.so" \
      --replace "koboldcpp_noavx2.so" "$out/lib/koboldcpp_noavx2.so" \
      --replace "koboldcpp_clblast.so" "$out/lib/koboldcpp_clblast.so" \
      --replace "koboldcpp_clblast_noavx2.so" "$out/lib/koboldcpp_clblast_noavx2.so" \
      --replace "koboldcpp_cublas.so" "$out/lib/koboldcpp_cublas.so" \
      --replace "koboldcpp_hipblas.so" "$out/lib/koboldcpp_hipblas.so" \
      --replace "koboldcpp_vulkan.so" "$out/lib/koboldcpp_vulkan.so" \
      --replace "klite.embd" "$out/lib/klite.embd" \
      --replace "kcpp_docs.embd" "$out/lib/kcpp_docs.embd" \
      --replace "rwkv_vocab.embd" "$out/lib/rwkv_vocab.embd" \
      --replace "rwkv_world_vocab.embd" "$out/lib/rwkv_world_vocab.embd"
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "https://github.com/LostRuins/koboldcpp";
    description = "A simple one-file way to run various GGML models with KoboldAI's UI.";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
