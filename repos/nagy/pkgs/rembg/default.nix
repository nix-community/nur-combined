{ pkgs, lib, fetchFromGitHub, buildPythonPackage, setuptools-scm, pymatting, filetype
, scikitimage, installShellFiles, pillow, flask, tqdm, waitress, requests
, fastapi, gdown, numpy, uvicorn, flatbuffers, asyncer, onnxruntime, coloredlogs
, sympy, opencv4, pytorch, torchvision, requireFile, runCommand, makeWrapper
, rembg, symlinkJoin }:

let
  mkGdriveDownload = { name, gdriveId, sha256 }:
    requireFile {
      inherit name sha256;
      url = "https://docs.google.com/uc?export=download&id=${gdriveId}";
    };
  # 168MB
  U2NET_PATH = mkGdriveDownload {
    name = "u2net.onnx";
    gdriveId = "1tCU5MM1LhRgGou5OpmpjBQbSrYIUoYab";
    sha256 = "sha256-jRDS87t1rjttUnx3lE/F59zZSymAnUenOaenKKkStJE=";
  };
  # 4MB
  U2NETP_PATH = mkGdriveDownload {
    name = "u2netp.onnx";
    gdriveId = "1tNuFmLv0TSNDjYIkjEdeH1IWKQdUA4HR";
    sha256 = "sha256-MJyEaSWN2nQnk9zg6+qObdOTF0+Jk0cz7MixTHb03dg=";
  };

  # human segment 168MB
  U2NET_HUMAN_SEG_PATH = mkGdriveDownload {
    name = "u2net_human_seg.onnx";
    gdriveId = "1ZfqwVxu-1XWC1xU1GHIP-FM_Knd_AX5j";
    sha256 = "sha256-AetqKaXE2O2zC1atrZuzoqBTUzjkgHJKIT4Kz9LRxzw=";
  };
  #
  # cloth segment 168MB
  U2NET_CLOTH_SEG_PATH = mkGdriveDownload {
    name = "u2net_cloth_seg.onnx";
    gdriveId = "15rKbQSXQzrKCQurUjZFg8HqzZad8bcyz";
    sha256 = "sha256-bSy8J7+9yYnh/TJWVtZZAuzGo8y+lLLTZV7BFO/LEo4=";
  };
  U2NET_HOME = symlinkJoin {
    name = "u2net_home";
    paths = map (u2:
      runCommand "u2net-as-directory" { }
      "mkdir $out && ln -s ${u2} $out/${u2.name}") [
        U2NET_PATH
        U2NETP_PATH
        U2NET_HUMAN_SEG_PATH
        U2NET_CLOTH_SEG_PATH
      ];
  };
in buildPythonPackage rec {
  pname = "rembg";
  version = "2.0.23";

  src = fetchFromGitHub {
    owner = "danielgatis";
    repo = "rembg";
    rev = "v${version}";
    sha256 = "sha256-UGVrt8tLThyJMKlstq4s/IdDJHcy4vlOWUzrppoPEM4=";
  };

  pythonImportsCheck = [ "rembg" ];

  doCheck = false;

  nativeBuildInputs = [ setuptools-scm installShellFiles ];

  prePatch = ''
    substituteInPlace requirements-gpu.txt --replace "==" ">="
    substituteInPlace requirements.txt \
       --replace numpy==1.22.3        numpy==1.23.1 \
       --replace opencv-python-headless==4.6.0.66        opencv \
       --replace scikit-image==0.19.1 scikit-image==0.18.3
    substituteInPlace requirements.txt --replace "==" ">="
    substituteInPlace setup.py --replace "~=" ">="
    # remove warning for newer pythons
    substituteInPlace rembg/__init__.py --replace "and sys.version_info.minor == 9" ""
  '';

  # to fix failing imports check
  preBuild = ''
    export NUMBA_CACHE_DIR=$TMPDIR
  '';

  propagatedBuildInputs = [
    pymatting
    filetype
    scikitimage
    pytorch
    torchvision

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
  ];

  passthru = {
    wrapped =
      runCommand "rembg-wrapped" { nativeBuildInputs = [ makeWrapper ]; } ''
        mkdir -p $out/bin
        makeWrapper ${rembg}/bin/rembg $out/bin/rembg \
              --prefix LD_LIBRARY_PATH : ${pkgs.onnxruntime}/lib \
              --set U2NET_HOME ${U2NET_HOME}
      '';
  };

  meta = with lib; {
    description = "Tool to remove images background";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
