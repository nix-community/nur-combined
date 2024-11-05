{
  stdenv,
  lib,
  fetchFromGitHub,
  python3Packages,
  rocmPackages,
  nix-update-script,
}:
let
  pname = "koboldcpp-rocm";
  version = "1.77.yr0-ROCm";

  src = fetchFromGitHub {
    owner = "YellowRoseCx";
    repo = "koboldcpp-rocm";
    rev = "v${version}";
    hash = "sha256-PcaLtqtdrv755RFiLn3LxCsqNtDJiWO8uxjB8NDkC74=";
  };

  koboldcpp-libs = stdenv.mkDerivation {
    pname = "${pname}-libs";
    inherit version src;

    enableParallelBuilding = true;

    buildInputs = with rocmPackages; [
      clr
      hipblas
      rocblas
    ];

    makeFlags = [
      "LLAMA_PORTABLE=1"
      "LLAMA_HIPBLAS=1"
      "CC=hipcc"
      "CXX=hipcc"
      "ROCM_PATH=${rocmPackages.clr}"
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      cp *.so $out/lib

      runHook postInstall
    '';
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    python3Packages.wrapPython
  ];

  pythonPath = with python3Packages; [
    numpy
    sentencepiece
    tkinter
    customtkinter
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib}
    install -m755 ./koboldcpp.py $out/bin/koboldcpp
    cp ./{klite.embd,kcpp_docs.embd,rwkv_vocab.embd,rwkv_world_vocab.embd} $out/lib
    cp ${koboldcpp-libs}/lib/*.so $out/lib

    substituteInPlace $out/bin/koboldcpp \
      --replace-quiet "koboldcpp_default.so" "$out/lib/koboldcpp_default.so" \
      --replace-quiet "koboldcpp_failsafe.so" "$out/lib/koboldcpp_failsafe.so" \
      --replace-quiet "koboldcpp_openblas.so" "$out/lib/koboldcpp_openblas.so" \
      --replace-quiet "koboldcpp_noavx2.so" "$out/lib/koboldcpp_noavx2.so" \
      --replace-quiet "koboldcpp_clblast.so" "$out/lib/koboldcpp_clblast.so" \
      --replace-quiet "koboldcpp_clblast_noavx2.so" "$out/lib/koboldcpp_clblast_noavx2.so" \
      --replace-quiet "koboldcpp_cublas.so" "$out/lib/koboldcpp_cublas.so" \
      --replace-fail "koboldcpp_hipblas.so" "$out/lib/koboldcpp_hipblas.so" \
      --replace-quiet "koboldcpp_vulkan.so" "$out/lib/koboldcpp_vulkan.so" \
      --replace-quiet "koboldcpp_vulkan_noavx2.so" "$out/lib/koboldcpp_vulkan_noavx2.so" \
      --replace-warn "klite.embd" "$out/lib/klite.embd" \
      --replace-warn "kcpp_docs.embd" "$out/lib/kcpp_docs.embd" \
      --replace-quiet "rwkv_vocab.embd" "$out/lib/rwkv_vocab.embd" \
      --replace-quiet "rwkv_world_vocab.embd" "$out/lib/rwkv_world_vocab.embd" \
      --replace-fail \'rocminfo\' \'${rocmPackages.rocminfo}/bin/rocminfo\'

    runHook postInstall
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "https://github.com/YellowRoseCx/koboldcpp-rocm";
    description = "A simple one-file way to run various GGML models with KoboldAI's UI with AMD ROCm offloading";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "koboldcpp";
  };
}
