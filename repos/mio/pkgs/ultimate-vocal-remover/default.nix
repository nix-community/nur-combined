{
  lib,
  fetchFromGitHub,
  fetchPypi,
  git,
  makeBinaryWrapper,
  python311Packages,
  ffmpeg,
  rubberband,
}:

let
  py = python311Packages.override {
    overrides = self: super: {
      terminado = super.terminado.overridePythonAttrs (_: {
        doCheck = false;
      });
    };
  };

  kthread = py.buildPythonPackage {
    pname = "kthread";
    version = "0.2.3-unstable-2022-02-20";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "munshigroup";
      repo = "kthread";
      rev = "bd20bb0ddd02fdd8ae0ee7f38c509f3e3e403b54";
      hash = "sha256-CKpbKBYz0oHSHHBSDSwqZ7SIjhidVjMQAgNayzwb76I=";
    };

    build-system = [ py.setuptools ];
    pythonImportsCheck = [ "kthread" ];
    nativeCheckInputs = [ py.pytestCheckHook ];

    meta = {
      description = "Killable threads in Python";
      license = lib.licenses.mit;
    };
  };

  matchering = py.buildPythonPackage rec {
    pname = "matchering";
    version = "2.0.6";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "sergree";
      repo = "matchering";
      rev = "refs/tags/${version}";
      hash = "sha256-9oSIzQ1GNdj76hJy4U1yPkS6dgdkhEvZBko6eYZMvYo=";
    };

    build-system = [ py.setuptools ];

    dependencies = with py; [
      numpy
      scipy
      soundfile
      resampy
      statsmodels
    ];

    pythonImportsCheck = [ "matchering" ];
    doCheck = false;

    meta = {
      description = "Open Source Audio Matching and Mastering";
      license = lib.licenses.gpl3Only;
    };
  };

  diffq = py.buildPythonPackage rec {
    pname = "diffq";
    version = "0.2.4";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "facebookresearch";
      repo = "diffq";
      rev = "refs/tags/v${version}";
      hash = "sha256-dW+l3T61v1QLKQpAsXi5zX5OhVHsg18ZhRfxPoTmhx4=";
    };

    build-system = [
      py.setuptools
      py.cython
    ];

    dependencies = with py; [
      numpy
      torch
    ];

    pythonImportsCheck = [ "diffq" ];
    doCheck = false;

    meta = {
      description = "Differentiable quantization using pseudo quantization noise";
      license = lib.licenses.cc-by-nc-nd-40;
    };
  };

  onnx_ir = py.buildPythonPackage rec {
    pname = "onnx_ir";
    version = "0.1.14";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-vWnjtYIQRtXXydD90CP44dDMmmLL7phvoOWrKxYC164=";
    };

    build-system = [ py.setuptools ];

    dependencies = with py; [
      numpy
      onnx
      py."typing-extensions"
      py."ml-dtypes"
    ];

    pythonImportsCheck = [ "onnx_ir" ];
  };

  onnxscript = py.buildPythonPackage rec {
    pname = "onnxscript";
    version = "0.5.7";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-SA1XJFG8Iz7X90K1AFywyJlZSy/cKOFRZ9qyb3/Xd60=";
    };

    build-system = [ py.setuptools ];
    nativeBuildInputs = [ git ];

    dependencies = with py; [
      py."ml-dtypes"
      numpy
      onnx
      onnx_ir
      packaging
      py."typing-extensions"
    ];

    pythonImportsCheck = [ "onnxscript" ];
  };

  onnx2pytorch = py.buildPythonPackage rec {
    pname = "onnx2pytorch";
    version = "0.4.1";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "Talmaj";
      repo = "onnx2pytorch";
      rev = "refs/tags/v${version}";
      hash = "sha256-rEoFh96/yAmfGKJ/7pz4YT3pgee+CrpZcbt5Yl/IlbU=";
    };

    build-system = [ py.setuptools ];

    patches = [
      ./onnx2pytorch-onnx-mapping.patch
      ./onnx2pytorch-ninf.patch
      ./onnx2pytorch-storage-order.patch
    ];

    dependencies = with py; [
      torch
      onnx
      onnxruntime
      onnxscript
      torchvision
    ];

    pythonImportsCheck = [ "onnx2pytorch" ];

    nativeCheckInputs = [
      py.pytestCheckHook
      onnxscript
    ];
    disabledTests = [
      "test_loop_sum" # module 'numpy' has no attribute 'bool'
      "test_single_layer_lstm"
      "test_instancenorm"
      "test_instancenorm_lazy"
    ];

    meta = {
      description = "Transform ONNX model to PyTorch representation";
      license = lib.licenses.asl20;
    };
  };

  pythonDeps = with py; [
    audioread
    certifi
    cffi
    cryptography
    einops
    future
    julius
    kthread
    librosa
    llvmlite
    matchering
    py."ml-collections"
    natsort
    omegaconf
    opencv4
    pillow
    psutil
    pydub
    pyglet
    pyperclip
    py."pytorch-lightning"
    pyyaml
    resampy
    scipy
    torch
    urllib3
    wget
    samplerate
    screeninfo
    diffq
    playsound
    onnx
    onnxruntime
    onnx2pytorch
    onnxscript
    onnx_ir
    soundfile
    numpy
    six
    tkinter
  ];

  pythonPath = py.makePythonPath pythonDeps;
in
py.buildPythonApplication rec {
  pname = "ultimate-vocal-remover";
  version = "5.6.0";
  format = "other";

  src = fetchFromGitHub {
    owner = "Anjok07";
    repo = "ultimatevocalremovergui";
    rev = "refs/tags/v5.6";
    hash = "sha256-2FV7qO40LcyJTrHiWeCzAPvelcgGc+InrsXv9/QGLkA=";
  };

  patches = [ ./uvr-data-dirs.patch ];

  nativeBuildInputs = [ makeBinaryWrapper ];
  propagatedBuildInputs = pythonDeps;
  dontBuild = true;
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/ultimate-vocal-remover
    cp -R . $out/share/ultimate-vocal-remover

    makeWrapper ${py.python.interpreter} $out/bin/ultimate-vocal-remover \
      --add-flags $out/share/ultimate-vocal-remover/UVR.py \
      --set PYTHONPATH "${pythonPath}:$out/share/ultimate-vocal-remover" \
      --prefix PATH : ${
        lib.makeBinPath [
          ffmpeg
          rubberband
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "GUI for a vocal remover that uses deep neural networks";
    homepage = "https://ultimatevocalremover.com/";
    license = lib.licenses.mit;
    mainProgram = "ultimate-vocal-remover";
    platforms = lib.platforms.linux;
  };
}
