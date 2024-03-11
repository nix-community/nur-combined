{
  pkgs,
  lib,
  python3Packages,
  buildPythonPackage ? python3Packages.buildPythonPackage,
  fetchPypi ? python3Packages.fetchPypi,
  auditok,
  pysubs2,
}:
buildPythonPackage rec {
  pname = "ffsubsync";
  version = "0.4.25";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-KnzqUQUDDaR4WkmtLBOcvNZ3xctXta+OHYWQJvp0ots=";
  };
  preBuild = ''
    rm ffsubsync/ffsubsync_gui.py
    cat > requirements.txt << EOF
    auditok==0.1.5
    chardet;python_version>='3.7'
    charset_normalizer
    faust-cchardet
    ffmpeg-python
    future>=0.18.2
    numpy>=1.12.0
    pysubs2;python_version<'3.7'
    pysubs2>=1.2.0;python_version>='3.7'
    rich
    six
    srt>=3.0.0
    tqdm
    typing_extensions
    webrtcvad;platform_system!='Windows'
    webrtcvad-wheels;platform_system=='Windows'
    EOF
  '';
  propagatedBuildInputs =
    (with python3Packages; [
      chardet
      charset-normalizer
      faust-cchardet
      ffmpeg-python
      future
      numpy
      rich
      six
      srt
      tqdm
      typing-extensions
      webrtcvad
    ])
    ++ [
      auditok
      pysubs2
    ];
  meta = with lib; {
    description = "Automagically synchronize subtitles with video";
    homepage = "https://github.com/smacke/ffsubsync";
    license = licenses.mit;
    maintainers = [];
  };
}
