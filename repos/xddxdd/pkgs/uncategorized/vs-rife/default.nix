{
  sources,
  lib,
  python3Packages,
  vapoursynth,
  ...
} @ args:
with python3Packages;
  buildPythonPackage {
    inherit (sources.vs-rife) pname version src;

    format = "pyproject";

    doCheck = false;

    postPatch = ''
      sed -i "/torch-tensorrt-fx-only/d" pyproject.toml
      sed -i "/VapourSynth/d" pyproject.toml
    '';

    propagatedBuildInputs = [
      hatchling
      numpy
      tensorrt
      torch
      tqdm
    ];

    meta = with lib; {
      description = "Real-Time Intermediate Flow Estimation for Video Frame Interpolation for VapourSynth";
      homepage = "https://github.com/HolyWu/vs-rife";
      license = licenses.mit;
      broken = true;
    };
  }
