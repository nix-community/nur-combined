{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ffmpeg-headless,
  hatchling,
  einops,
  huggingface-hub,
  julius,
  lameenc,
  pyyaml,
  safetensors,
  sphn,
  torch,
  tqdm,
  nix-update-script,
}:
buildPythonPackage (finalAttrs: {
  pname = "demucs";
  version = "4.1.0";
  __structuredAttrs = true;
  pyproject = true;

  # facebookresearch/demucs stopped at 4.0.1.
  src = fetchFromGitHub {
    owner = "adefossez";
    repo = "demucs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EvuiLGemggYMIDEtvjNYuBeNJdfSQIAlZDY/6lGUQto=";
  };

  postPatch = ''
    substituteInPlace demucs/audio.py \
      --replace-fail "'ffprobe'" "'${lib.getExe' ffmpeg-headless "ffprobe"}'" \
      --replace-fail "'ffmpeg'" "'${lib.getExe ffmpeg-headless}'"
  '';

  build-system = [ hatchling ];

  dependencies = [
    einops
    huggingface-hub
    julius
    lameenc
    pyyaml
    safetensors
    sphn
    torch
    tqdm
  ];

  pythonImportsCheck = [
    "demucs.api"
    "demucs.separate"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Music source separation in the waveform domain";
    homepage = "https://github.com/adefossez/demucs";
    changelog = "https://github.com/adefossez/demucs/blob/${finalAttrs.src.tag}/docs/release.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "demucs";
  };
})
