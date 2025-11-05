{
  lib,
  python3,
  fetchPypi,
  python3Packages,
  nix-update-script,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "ffmpeg-quality-metrics";
  version = "3.7.1";
  format = "wheel";

  src = fetchPypi rec {
    inherit version format;
    pname = "ffmpeg_quality_metrics";
    sha256 = "sha256-8E6IxTh8vbqqbT3nIQo8k+fOCfcoXTiLDSKpE9HET0g=";
    dist = python;
    python = "py3";
    abi = "none";
    platform = "any";
  };

  propagatedBuildInputs = with python3Packages; [
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
    description = " Calculate quality metrics with FFmpeg (SSIM, PSNR, VMAF, VIF)";
    homepage = "https://github.com/slhck/ffmpeg-quality-metrics";
    platforms = lib.platforms.all;
  };
}
