{ fetchFromGitHub, igorski }:
igorski.mkVst3 (finalAttrs: {
  pname = "transformant";
  version = "1.0.4";
  src = fetchFromGitHub {
    owner = "igorski";
    repo = "transformant";
    rev = finalAttrs.version;
    hash = "sha256-GSZ98Q2tjpbVzkyxasX1lQiTfqZ7eOiAJCNFbpLvsCo=";
  };

  meta = {
    description = "VST plugin that acts as a multi channel formant filter";
    homepage = "https://www.igorski.nl/download/transformant";
  };
})
