{ fetchFromGitHub, igorski }:
igorski.mkVst3 (finalAttrs: {
  pname = "fogpad";
  version = "1.0.3-3.7.10";
  src = fetchFromGitHub {
    owner = "igorski";
    repo = "fogpad";
    rev = finalAttrs.version;
    hash = "sha256-7eVKdsLWCmQaEVCPMLwqiySe1dnXcDvBqaq0Ip15dO0=";
  };

  meta = {
    description = "A VST reverb effect in which the reflections can be frozen, filtered, pitch shifted and ultimately disintegrated";
    homepage = "https://www.igorski.nl/download/fogpad";
  };
})
