{ lib
, python312Packages
, auditok
, pysubs2
,
}: python312Packages.buildPythonPackage rec {
  pname = "ffsubsync";
  version = "0.4.26";
  src = python312Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-GsA6gy7bqdqIzu7XU+Laqk5iC2Mv15SXEMsxUWthFBA=";
  };
  pyproject = true;
  build-system = with python312Packages; [ setuptools ];
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
    (with python312Packages; [
      chardet
      charset-normalizer
      faust-cchardet
      ffmpeg-python
      future
      numpy
      rich
      setuptools
      six
      srt
      tqdm
      typing-extensions
      webrtcvad
    ])
    ++ [
      (auditok.override {
        python3Packages = python312Packages;
      })
      (pysubs2.override {
        python3Packages = python312Packages;
      })
    ];
  meta = with lib; {
    description = "Automagically synchronize subtitles with video";
    homepage = "https://github.com/smacke/ffsubsync";
    license = licenses.mit;
    maintainers = [ lib.maintainers.kugland ];
    mainProgram = "ffsubsync";
  };
}
