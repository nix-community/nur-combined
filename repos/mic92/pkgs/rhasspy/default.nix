{ callPackage }: rec {
  dataclasses-json = callPackage ./dataclasses-json {
    inherit typing-inspect;
  };

  hypercorn = callPackage ./hypercorn {};

  kaldi = callPackage ./kaldi {};

  quart = callPackage ./quart {
    inherit hypercorn;
  };

  quart-cors = callPackage ./quart-cors {
    inherit quart;
  };

  rapidfuzz = callPackage ./rapidfuzz {};

  rhasspy-hermes = callPackage ./rhasspy-hermes {
    inherit dataclasses-json;
  };

  rhasspy-asr = callPackage ./rhasspy-asr {};

  rhasspy-asr-kaldi = callPackage ./rhasspy-asr-kaldi {
    inherit rhasspy-asr rhasspy-nlu;
  };

  rhasspy-asr-kaldi-hermes = callPackage ./rhasspy-asr-kaldi-hermes {
    inherit rhasspy-hermes rhasspy-asr-kaldi rhasspy-silence;
  };

  rhasspy-fuzzywuzzy = callPackage ./rhasspy-fuzzywuzzy {
    inherit rhasspy-nlu rapidfuzz;
  };

  rhasspy-fuzzywuzzy-hermes = callPackage ./rhasspy-fuzzywuzzy-hermes {
    inherit rhasspy-fuzzywuzzy rhasspy-hermes rhasspy-nlu;
  };

  rhasspy-microphone-pyaudio-hermes = callPackage ./rhasspy-microphone-pyaudio-hermes {
    inherit rhasspy-hermes;
  };

  rhasspy-nlu = callPackage ./rhasspy-nlu {};

  rhasspy-remote-http-hermes = callPackage ./rhasspy-remote-http-hermes {
    inherit rhasspy-hermes rhasspy-nlu rhasspy-silence;
  };

  rhasspy-silence = callPackage ./rhasspy-silence {};

  rhasspy-tts-cli-hermes = callPackage ./rhasspy-tts-cli-hermes {
    inherit rhasspy-hermes;
  };

  rhasspy-wake-porcupine-hermes = callPackage ./rhasspy-wake-porcupine-hermes {
    inherit rhasspy-hermes;
  };

  rhasspy-dialogue-hermes = callPackage ./rhasspy-dialogue-hermes  {
    inherit rhasspy-hermes;
  };

  rhasspy-speakers-cli-hermes = callPackage ./rhasspy-speakers-cli-hermes  {
    inherit rhasspy-hermes;
  };

  rhasspy-microphone-cli-hermes = callPackage ./rhasspy-microphone-cli-hermes  {
    inherit rhasspy-hermes;
  };

  rhasspy-rasa-nlu-hermes = callPackage ./rhasspy-rasa-nlu-hermes  {
    inherit rhasspy-hermes rhasspy-nlu;
  };

  rhasspy-nlu-hermes = callPackage ./rhasspy-nlu-hermes  {
    inherit rhasspy-hermes rhasspy-nlu;
  };

  rhasspy-homeassistant-hermes = callPackage ./rhasspy-homeassistant-hermes {
    inherit rhasspy-hermes;
  };

  pydash = callPackage ./pydash {};

  opengrm-ngram = callPackage ./opengrm-ngram {};

  json5 = callPackage ./json5 {};

  rhasspy-profile = callPackage ./rhasspy-profile {
    inherit pydash json5;
  };

  rhasspy-supervisor = callPackage ./rhasspy-supervisor {
    inherit rhasspy-profile;
  };

  rhasspy-server-hermes = callPackage ./rhasspy-server-hermes {
    inherit rhasspy-hermes
      rhasspy-profile
      rhasspy-nlu
      swagger-ui-py
      rhasspy-supervisor
      quart
      quart-cors;
  };

  rhasspy = callPackage ./rhasspy {
    inherit kaldi
      opengrm-ngram
      phonetisaurus
      rhasspy-asr-kaldi-hermes
      rhasspy-dialogue-hermes
      rhasspy-tts-cli-hermes
      rhasspy-wake-porcupine-hermes
      rhasspy-remote-http-hermes
      rhasspy-fuzzywuzzy-hermes
      rhasspy-speakers-cli-hermes
      rhasspy-microphone-cli-hermes
      rhasspy-microphone-pyaudio-hermes
      rhasspy-rasa-nlu-hermes
      rhasspy-nlu-hermes
      rhasspy-homeassistant-hermes
      rhasspy-supervisor
      rhasspy-server-hermes
    ;
  };

  swagger-ui-py = callPackage ./swagger-ui-py {};

  phonetisaurus = callPackage ./phonetisaurus {};

  typing-inspect = callPackage ./typing-inspect {};
}
