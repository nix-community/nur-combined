{ fetchFromGitHub, igorski }:
igorski.mkVst3 (finalAttrs: {
  pname = "vstsid";
  version = "1.1.2";
  src = fetchFromGitHub {
    owner = "igorski";
    repo = "VSTSID";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pcX5CJsVJCa/E22B6GF2z3BIzfjkjbjVyZx7118qarU=";
  };

  meta = {
    description = "VST plugin version of the WebSID Commodore 64 synthesizer";
    homepage = "https://www.igorski.nl/download/vstsid";
  };
})
