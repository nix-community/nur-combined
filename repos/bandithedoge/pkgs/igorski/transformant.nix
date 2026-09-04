{ fetchFromGitHub, igorski }:
igorski.mkVst3 (finalAttrs: {
  pname = "transformant";
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "igorski";
    repo = "transformant";
    rev = finalAttrs.version;
    hash = "sha256-lLsFiJDcgq+opTAILW4dpa41ZCQgiJFpd4CFJCTSmNI=";
  };

  meta = {
    description = "VST plugin that acts as a multi channel formant filter";
    homepage = "https://www.igorski.nl/download/transformant";
  };
})
