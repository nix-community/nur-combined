{ pkgs, lib, fetchurl, fetchFromGitHub, buildPythonPackage, setuptools-scm
, pymatting, filetype, scikitimage, installShellFiles, pillow, flask, tqdm
, waitress, requests, fastapi, gdown, numpy, uvicorn, flatbuffers, asyncer
, onnxruntime, coloredlogs, sympy, opencv4, requireFile, runCommand, makeWrapper
, rembg, pooch, symlinkJoin, imagehash }:

let
  models = lib.mapAttrsToList (name: value:
    fetchurl {
      name = name;
      url =
        "https://github.com/danielgatis/rembg/releases/download/v0.0.0/${name}.onnx";
      sha256 = value;
    }) {
      u2net = "sha256-jRDS87t1rjttUnx3lE/F59zZSymAnUenOaenKKkStJE="; # 168MB
      u2netp = "sha256-MJyEaSWN2nQnk9zg6+qObdOTF0+Jk0cz7MixTHb03dg="; # 4MB
      u2net_human_seg =
        "sha256-AetqKaXE2O2zC1atrZuzoqBTUzjkgHJKIT4Kz9LRxzw="; # human segment 168MB
      u2net_cloth_seg =
        "sha256-bSy8J7+9yYnh/TJWVtZZAuzGo8y+lLLTZV7BFO/LEo4="; # cloth segment 168MB
    };
  U2NET_HOME = symlinkJoin {
    name = "u2net-home";
    paths = map (x:
      runCommand "u2net_home" { }
      "mkdir $out && ln -s ${x} $out/${x.name}.onnx ") models;
  };
in buildPythonPackage rec {
  pname = "rembg";
  version = "2.0.30";

  src = fetchFromGitHub {
    owner = "danielgatis";
    repo = "rembg";
    rev = "v${version}";
    sha256 = "sha256-XysPy5rckUQ6HSRzIyjKKHyhrqAul3vzBHvr45j/CSg=";
  };

  nativeBuildInputs = [ setuptools-scm installShellFiles ];

  # pythonRelaxDeps = true;

  prePatch = ''
    substituteInPlace setup.py \
      --replace "numpy~=1.23.5" "numpy" \
      --replace "opencv-python-headless~=4.6.0.66" "opencv" \
      --replace "~=" ">="
  '';

  propagatedBuildInputs = [
    pymatting
    filetype
    scikitimage
    # pytorch
    # torchvision

    requests
    flask
    tqdm
    waitress
    fastapi
    gdown
    pillow
    numpy
    uvicorn
    asyncer

    onnxruntime
    flatbuffers
    sympy
    coloredlogs
    opencv4
    pooch
    imagehash
  ];

  makeWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${pkgs.onnxruntime}/lib "
    "--set U2NET_HOME ${U2NET_HOME}"
  ];

  # to fix failing imports check
  preInstallCheck = ''
    export NUMBA_CACHE_DIR=$TMPDIR
  '';

  pythonImportsCheck = [ "rembg" ];

  meta = with lib; {
    description = "Tool to remove images background";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
