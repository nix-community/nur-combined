{
  pkgs,
  lib,
  fetchurl,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools-scm,
  pymatting,
  jsonschema,
  filetype,
  scikitimage,
  installShellFiles,
  pillow,
  tqdm,
  fastapi,
  numpy,
  uvicorn,
  asyncer,
  aiohttp,
  gradio,
  onnxruntime,
  opencv4,
  runCommandLocal,
  rembg,
  pooch,
  watchdog,
  symlinkJoin,
  imagehash,
  testers,
}:

let
  models =
    lib.mapAttrsToList
      (
        name: hash:
        fetchurl {
          inherit name hash;
          url = "https://github.com/danielgatis/rembg/releases/download/v0.0.0/${name}.onnx";
        }
      )
      {
        u2net = "sha256-jRDS87t1rjttUnx3lE/F59zZSymAnUenOaenKKkStJE=";
        u2netp = "sha256-MJyEaSWN2nQnk9zg6+qObdOTF0+Jk0cz7MixTHb03dg=";
        u2net_human_seg = "sha256-AetqKaXE2O2zC1atrZuzoqBTUzjkgHJKIT4Kz9LRxzw=";
        u2net_cloth_seg = "sha256-bSy8J7+9yYnh/TJWVtZZAuzGo8y+lLLTZV7BFO/LEo4=";
        silueta = "sha256-ddpsjS+Alux0PQcZUb5ztKi8ez5R2aZiXWNkT5D/7ts=";
        isnet-general-use = "sha256-YJIOmcRUZPK6V77irQjJGaUrv4UnOelpR/u0NYwNlko=";
      };
  U2NET_HOME = symlinkJoin {
    name = "u2net-home";
    paths = map (
      x:
      runCommandLocal "u2net_home" { } ''
        mkdir $out && ln -s ${x} $out/${x.name}.onnx
      ''
    ) models;
  };
in
buildPythonPackage rec {
  pname = "rembg";
  version = "2.0.65";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "danielgatis";
    repo = "rembg";
    rev = "v${version}";
    sha256 = "sha256-o6M3DSW1GL3xvEx4lsE325J3XcmRrhhPszS5MkaynsE=";
  };

  nativeBuildInputs = [
    setuptools-scm
    installShellFiles
  ];

  # pythonRelaxDeps = true;

  prePatch = ''
    substituteInPlace setup.py \
      --replace "opencv-python-headless" "opencv"
  '';

  propagatedBuildInputs = [
    asyncer
    fastapi
    filetype
    imagehash
    numpy
    onnxruntime
    opencv4
    pillow
    pooch
    pymatting
    scikitimage
    tqdm
    uvicorn
    gradio
    watchdog
    jsonschema
    aiohttp
  ];

  makeWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${pkgs.onnxruntime}/lib "
    "--set U2NET_HOME ${U2NET_HOME}"
  ];

  # to fix failing imports check
  preInstallCheck = ''
    export NUMBA_CACHE_DIR=$TMPDIR
  '';
  # doInstallCheck = false;
  doCheck = false;
  # pythonImportsCheck = [ "rembg" ];

  passthru.tests.version = (testers.testVersion { package = rembg; }).overrideAttrs {
    NUMBA_CACHE_DIR = "/tmp";
  };

  meta = {
    description = "Tool to remove images background";
    homepage = "https://github.com/danielgatis/rembg";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
