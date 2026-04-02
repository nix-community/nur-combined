{
  lib,
  fetchFromGitHub,
  nix-update-script,

  # python packages
  buildPythonApplication,
  ffmpeg-progress-yield,
  uv-build,
}:

buildPythonApplication rec {
  pname = "ffmpeg-quality-metrics";
  version = "3.11.3";
  pyproject = true;

  pythonRelaxDeps = true;

  src = fetchFromGitHub {
    owner = "slhck";
    repo = "ffmpeg-quality-metrics";
    tag = "v${version}";
    hash = "sha256-MC1Xw+glFeUNBlgKPQ4Tf6kqDz+XPxDIDY8Q75sMXTE=";
  };

  build-system = [
    uv-build
  ];

  dependencies = [
    ffmpeg-progress-yield
  ];

  postPatch = ''
    sed -i 's/requires = \["uv_build[^"]*"]/requires = ["uv_build"]/' pyproject.toml
    sed -i '/license-files = \["LICENSE.md"]/d' pyproject.toml
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      pname
    ];
  };

  meta = {
    homepage = "https://github.com/slhck/ffmpeg-quality-metrics";
    mainProgram = "ffmpeg-quality-metrics";
    changelog = "https://github.com/slhck/ffmpeg-quality-metrics/releases/tag/v${version}";
    description = "Calculates video quality metrics with FFmpeg (SSIM, PSNR, VMAF, VIF)";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
