{
  lib,
  fetchFromGitHub,
  python3Packages,
  nix-update-script,
}:
python3Packages.buildPythonApplication rec {
  pname = "ffmpeg-quality-metrics";
  version = "3.10.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "slhck";
    repo = "ffmpeg-quality-metrics";
    tag = "v${version}";
    hash = "sha256-immWhYUsX9zEHLqJeBh3AjzEJn43HArFU9f4yIujNX0=";
  };

  build-system = with python3Packages; [
    uv-build
  ];

  dependencies = with python3Packages; [
    ffmpeg-progress-yield
  ];

  passthru = {
    updateScript = lib.concatStringsSep " " (nix-update-script {
      extraArgs = [
        "--commit"
        "${pname}"
      ];
    });
  };

  meta = {
    description = "Calculate quality metrics with FFmpeg (SSIM, PSNR, VMAF, VIF)";
    homepage = "https://github.com/slhck/ffmpeg-quality-metrics";
    platforms = lib.platforms.all;
  };
}
