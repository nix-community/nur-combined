{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  ffmpeg-python,
  ffmpeg-full,
}:

let ffmpeg = ffmpeg-full; in

buildPythonPackage (finalAttrs: {
  pname = "stempeg";
  version = "0.2.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "faroit";
    repo = "stempeg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hnvfZuRgBtb8F6Wjm3fncuS6l5qR3sEkgwBZwXUNVec=";
  };

  postPatch = ''
    # use ffmpeg from env, or fallback to default ffmpeg
    substituteInPlace stempeg/cmds.py \
      --replace \
        'FFMPEG_PATH = find_cmd("ffmpeg")' \
        'FFMPEG_PATH = find_cmd("ffmpeg") or "${ffmpeg}/bin/ffmpeg"' \
      --replace \
        'FFPROBE_PATH = find_cmd("ffprobe")' \
        'FFPROBE_PATH = find_cmd("ffprobe") or "${ffmpeg}/bin/ffprobe"'
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    ffmpeg-python
  ];

  pythonImportsCheck = [
    "stempeg"
  ];

  meta = {
    description = "Python I/O for STEM audio files";
    homepage = "https://github.com/faroit/stempeg";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
