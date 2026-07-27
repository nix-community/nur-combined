{ runCommand, python3Packages }:

let
  inherit (python3Packages.some-pkgs-py) nvdiffrast;
in
runCommand "nvdiffrast-gpu-tests-${nvdiffrast.version}"
{
  nativeBuildInputs = [
    (python3Packages.python.withPackages (ps: [
      nvdiffrast
      ps.torch
      ps.imageio
      ps.imageio-ffmpeg
    ]))
  ];
  meta.broken = !python3Packages.torch.cudaSupport;
  requiredSystemFeatures = [ "cuda" ];
}
  ''
    python -m nvdiffrast.samples.torch.envphong --opengl --outdir "$out"
  ''
