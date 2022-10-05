{ lib
, buildPythonPackage
, fetchFromGitHub
, pytorch
, torchvision
, pytestCheckHook
, pytest-xdist
, ezy-expecttest
}:


let
  pname = "timm";
  version = "0.6.11";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "rwightman";
    repo = "pytorch-image-models";
    rev = "v${version}";
    hash = "sha256-wtxqK4VsBK2456UI6AXDAeCJTvylNPUc81SPL5xA6NI=";
  };

  # Bring your own instance
  buildInputs = [
    pytorch
    torchvision
  ];

  checkInputs = [
    pytestCheckHook
    pytest-xdist
    ezy-expecttest
  ];

  preCheck = ''
    export GITHUB_ACTIONS=1
  '';
  pytestFlagsArray = [
    "./tests/"
    "-vvv"
    "--maxfail"
    "2"
    # Since there are just too many of them
    "-k"
    "resnet18d"
  ];

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.asl20;
    description = "PyTorch image models, scripts, weights. Used by Quad-Tree-Attention";
    homepage = "https://github.com/rwightman/pytorch-image-models";
    platforms = lib.platforms.unix;
  };
}
