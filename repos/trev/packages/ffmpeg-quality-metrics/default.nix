{
  lib,
  fetchFromGitHub,
  python3Packages,
  nix-update-script,
}:
python3Packages.buildPythonApplication rec {
  pname = "ffmpeg-quality-metrics";
  version = "3.7.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "slhck";
    repo = "ffmpeg-quality-metrics";
    tag = "v${version}";
    hash = "sha256-YLxnGYAsraUiEnbgJwZpTs24RXY0xKNmfbjDQJklKas=";
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
