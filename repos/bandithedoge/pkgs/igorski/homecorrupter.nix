{ fetchFromGitHub, igorski }:
igorski.mkVst3 (finalAttrs: {
  pname = "homecorrupter";
  version = "1.1.3";
  src = fetchFromGitHub {
    owner = "igorski";
    repo = "homecorrupter";
    rev = finalAttrs.version;
    hash = "sha256-jFD0orWRELJE5CKAxqNF8KKtS9kMnAzrqZTPX8FoRUQ=";
  };

  meta = {
    description = "VST plugin that reduces sampling rate, bit depth and playback speed on-the-fly";
    homepage = "https://www.igorski.nl/download/homecorrupter";
  };
})
