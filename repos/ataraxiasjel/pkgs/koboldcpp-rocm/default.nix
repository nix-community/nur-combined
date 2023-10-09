{ stdenv
, lib
, fetchFromGitHub
, fetchPypi
, python3
, pkg-config
, hip
, hipblas
, rocblas
, nix-update-script
}:
let
  pname = "koboldcpp-rocm";
  version = "unstable-2023-10-09";

  src = fetchFromGitHub {
    owner = "YellowRoseCx";
    repo = pname;
    rev = "b01a449c21018e58c549cf81f7cadef7381d1d5d";
    hash = "sha256-D7p5RZlgIMeag7IP5RBdidiJdNEiq6OhCfsB2G+0w7A=";
  };

  koboldcpp-rocm-libs = stdenv.mkDerivation {
    pname = "${pname}-libs";
    inherit version src;

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ hip hipblas rocblas ];

    postPatch = ''
      substituteInPlace Makefile \
        --replace "\$(shell \$(ROCM_PATH)/llvm/bin/amdgpu-arch)" ""
    '';

    makeFlags = [
      "LLAMA_HIPBLAS=1"
      "CC=hipcc"
      "CXX=hipcc"
      "ROCM_PATH=${hip}"
      # "GPU_TARGETS=${gpuTargets}"
    ];

    installPhase = ''
      mkdir -p $out/lib
      cp *.so $out/lib
    '';
  };

  darkdetect = with python3.pkgs; buildPythonPackage rec {
    pname = "darkdetect";
    version = "0.8.0";
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-tUKOEXAmPrXepEwl3DiV7ddeb1IwCYY1PNY1M/59+LE=";
    };

    buildInputs =  [ setuptools ];

    meta = with lib; {
      homepage = "https://github.com/albertosottile/darkdetect";
      description = " Detect OS Dark Mode from Python";
      license = licenses.mit;
      maintainers = with maintainers; [ ataraxiasjel ];
    };
  };

  customtkinter = with python3.pkgs; buildPythonPackage rec {
    pname = "customtkinter";
    version = "5.2.0";
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-6TRIqNIhIeIOwW6VlgqDBuF89+AHl2b1gEsuhV5hSTc=";
    };

    buildInputs =  [ setuptools ];
    propagatedBuildInputs = [ darkdetect typing-extensions ];

    meta = with lib; {
      changelog = "https://github.com/TomSchimansky/CustomTkinter/releases/tag/${version}";
      homepage = "https://github.com/TomSchimansky/CustomTkinter";
      description = "A modern and customizable python UI-library based on Tkinter";
      license = licenses.mit;
      maintainers = with maintainers; [ ataraxiasjel ];
    };
  };

  gguf = with python3.pkgs; buildPythonPackage rec {
    pname = "gguf";
    version = "0.3.0";
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-HyfWaF4/h7UPiP1XQTbFMU9B1nVzI0BFyDNchRsxHjw=";
    };

    buildInputs =  [ setuptools poetry-core ];
    propagatedBuildInputs = [ numpy ];

    meta = with lib; {
      homepage = "https://github.com/ggerganov/llama.cpp";
      description = "Write ML models in GGUF for GGML";
      license = licenses.mit;
      maintainers = with maintainers; [ ataraxiasjel ];
    };
  };
in stdenv.mkDerivation {
  inherit pname version src;

  propagatedBuildInputs = [
    (python3.withPackages (ps: with ps; [
      numpy sentencepiece tkinter customtkinter gguf
    ]))
  ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/{bin,lib}
    install -m755 ./koboldcpp.py $out/bin/koboldcpp
    cp ./{klite.embd,rwkv_vocab.embd,rwkv_world_vocab.embd} $out/lib
    cp ${koboldcpp-rocm-libs}/lib/*.so $out/lib

    substituteInPlace $out/bin/koboldcpp \
      --replace "koboldcpp_default.so" "$out/lib/koboldcpp_default.so" \
      --replace "koboldcpp_failsafe.so" "$out/lib/koboldcpp_failsafe.so" \
      --replace "koboldcpp_cublas.so" "$out/lib/koboldcpp_cublas.so" \
      --replace "klite.embd" "$out/lib/klite.embd" \
      --replace "rwkv_vocab.embd" "$out/lib/rwkv_vocab.embd" \
      --replace "rwkv_world_vocab.embd" "$out/lib/rwkv_world_vocab.embd"
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = with lib; {
    homepage = "https://github.com/YellowRoseCx/koboldcpp-rocm";
    description = "A simple one-file way to run various GGML models with KoboldAI's UI with AMD ROCm offloading";
    license = licenses.agpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
