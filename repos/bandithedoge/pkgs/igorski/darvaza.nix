{ fetchFromGitHub, igorski }:
igorski.mkVst3 (finalAttrs: {
  pname = "darvaza";
  version = "1.0.3";
  src = fetchFromGitHub {
    owner = "igorski";
    repo = "darvaza";
    rev = finalAttrs.version;
    hash = "sha256-NvPpTEBNGhz6fcbfJndRSWVcEbnTZafFxkFAGUMNy+Q=";
  };

  meta = {
    description = "Darvaza is a multichannel audio gate with a twist : whenever the gate closes on your input signal, you get a perversion of your source spat back at you";
    homepage = "https://www.igorski.nl/download/darvaza";
  };
})
