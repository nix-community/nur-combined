{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, portaudio
, swig
, autoreconfHook
, pkg-config
, autoconf-archive
, gfortran
, lapack
, blas
, makeWrapper
, rhasspy-asr-kaldi-hermes
, rhasspy-dialogue-hermes
, rhasspy-tts-cli-hermes
, rhasspy-wake-porcupine-hermes
, rhasspy-remote-http-hermes
, rhasspy-fuzzywuzzy-hermes
, rhasspy-speakers-cli-hermes
, rhasspy-microphone-cli-hermes
, rhasspy-microphone-pyaudio-hermes
, rhasspy-homeassistant-hermes
, rhasspy-rasa-nlu-hermes
, rhasspy-nlu-hermes
, rhasspy-supervisor
, rhasspy-server-hermes
, supervisor
, mosquitto
, kaldi
, openfst
, opengrm-ngram
, phonetisaurus
}:

buildPythonPackage rec {
  pname = "rhasspy";
  version = "2.5.0";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "0k03f43fii9sgn3chv0h6432p9965di2d35032nazzd1h0n8vgpj";
  };

  configureFlags = [
    "RHASSPY_WAKE_SYSTEM=porcupine"
    "RHASSPY_SPEECH_SYSTEM=kaldi"
    "RHASSPY_LANGUAGE=en"
    "--disable-precompiled-binaries"
    "--disable-virtualenv"
  ];

  patches = [
    ./0001-kaldi-don-t-depend-on-atlas.patch
    ./0001-make-mycroft-precise-optional.patch
  ];

  postPatch = ''
    sed -i -e 's/is_virtualenv_enabled=yes/is_virtualenv_enabled=no/' configure.ac
  '';

  postInstall = ''
    install -D -m755 rhasspy.sh $out/bin/rhasspy
    install -D -m755 --target $out/bin bin/*
    mkdir -p $out/share/rhasspy
    cp -r etc $out/share/rhasspy
    wrapProgram $out/bin/rhasspy \
      --prefix PATH : "${lib.makeBinPath [
        supervisor
        rhasspy-dialogue-hermes
        rhasspy-asr-kaldi-hermes
        rhasspy-tts-cli-hermes
        rhasspy-wake-porcupine-hermes
        rhasspy-remote-http-hermes
        rhasspy-fuzzywuzzy-hermes
        rhasspy-speakers-cli-hermes
        rhasspy-microphone-cli-hermes
        rhasspy-microphone-pyaudio-hermes
        rhasspy-rasa-nlu-hermes
        rhasspy-homeassistant-hermes
        rhasspy-server-hermes
        rhasspy-nlu-hermes
        mosquitto
        kaldi
        openfst
        opengrm-ngram
        phonetisaurus
      ]}" \
      --set PYTHONPATH "$PYTHONPATH"
     ln -s -t $out/share/rhasspy ${rhasspy-server-hermes}/share/rhasspy/{web,templates}
     mkdir -p $out/lib/kaldi
     ln -s ${kaldi}/bin/* $out/lib/kaldi
     ln -s ${kaldi}/share/kaldi/egs $out/lib/kaldi
  '';

  buildInputs = [
    portaudio
    lapack
    blas
  ];

  nativeBuildInputs = [
    swig
    makeWrapper
    autoreconfHook
    pkg-config
    autoconf-archive
    gfortran
  ];

  propagatedBuildInputs = [
    rhasspy-dialogue-hermes
    rhasspy-asr-kaldi-hermes
    rhasspy-tts-cli-hermes
    rhasspy-wake-porcupine-hermes
    rhasspy-remote-http-hermes
    rhasspy-fuzzywuzzy-hermes
    rhasspy-speakers-cli-hermes
    rhasspy-microphone-cli-hermes
    rhasspy-microphone-pyaudio-hermes
    rhasspy-rasa-nlu-hermes
    rhasspy-homeassistant-hermes
    rhasspy-server-hermes
    rhasspy-nlu-hermes
    rhasspy-supervisor
    mosquitto
  ];

  meta = with lib; {
    description = "Combination of multiple Rhasspy services running together";
    homepage = "https://github.com/rhasspy/rhasspy";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
