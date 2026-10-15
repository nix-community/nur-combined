{
  lib,
  python3Packages,
  fetchPypi,
  ffmpeg,
  makeWrapper,
}:

python3Packages.buildPythonApplication rec {
  pname = "scanverdict";
  version = "1.1.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-95Pw/rw5VyUAJN1YgIxnk5yZpuaf6kePpAgNwROzuTw=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = [ python3Packages.numpy ];

  nativeBuildInputs = [ makeWrapper ];

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    ffmpeg
  ];

  pythonImportsCheck = [ "scanverdict" ];

  postFixup = ''
    wrapProgram $out/bin/scanverdict --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
  '';

  meta = {
    description = "Tell what scan type and cadence a video file really has, then prove the fix works";
    homepage = "https://github.com/Booyaka101/scanverdict";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lunik1 ];
    mainProgram = "scanverdict";
    platforms = lib.platforms.all;
  };
}
