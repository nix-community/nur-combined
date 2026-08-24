{ fetchFromGitHub, igorski }:
igorski.mkVst3 (finalAttrs: {
  pname = "regrader";
  version = "1.0.5";
  src = fetchFromGitHub {
    owner = "igorski";
    repo = "regrader";
    rev = finalAttrs.version;
    hash = "sha256-tu1xfsnlc+55BdheF9y1N8OyeCrugGu+bHNg6tFK8Ys=";
  };

  meta = {
    description = "VST delay plugin where the repeats degrade in resolution";
    homepage = "https://www.igorski.nl/download/regrader";
  };
})
