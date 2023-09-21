{ lib
, buildPythonPackage
, callPackage
, einops
, fetchFromGitHub
, flow-vis
, hydra-core
, matplotlib
, mediapy
, moviepy
, opencv4
, setuptools
, timm
, torch
, torchvision
, wheel
}:

buildPythonPackage rec {
  pname = "co-tracker";
  version = "unstable-2023-09-14";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "facebookresearch";
    repo = "co-tracker";
    rev = "4f297a92fe1a684b1b0980da138b706d62e45472";
    hash = "sha256-71yXQ44ra6uOlWhAXdLNMu2CPub+Kp5UHClQtECubbs=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    einops
    flow-vis
    hydra-core
    matplotlib
    mediapy
    moviepy
    opencv4
    timm
    torch
    torchvision
  ];

  pythonImportsCheck = [ "cotracker" ];

  # E.g. .#pkgsUnfree.python3Packages.co-tracker.passthru.datasets.config.weights.stride_4_wind_8.package
  passthru.datasets = callPackage ./data.nix { };

  meta = with lib; {
    description = "CoTracker is a model for tracking any point (pixel) on a video";
    homepage = "https://github.com/facebookresearch/co-tracker/";
    license = licenses.cc-by-nc-40;
    maintainers = with maintainers; [ SomeoneSerge ];
  };
}
