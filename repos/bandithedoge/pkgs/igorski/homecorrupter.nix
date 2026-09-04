{ fetchFromGitHub, igorski }:
igorski.mkVst3 (finalAttrs: {
  pname = "homecorrupter";
  version = "1.2.0";
  src = fetchFromGitHub {
    owner = "igorski";
    repo = "homecorrupter";
    rev = finalAttrs.version;
    hash = "sha256-oGKhPtiv+HO7IPoZCmaaDErwF9sig8y+1B/iSZOL7iU=";
  };

  meta = {
    description = "VST plugin that reduces sampling rate, bit depth and playback speed on-the-fly";
    homepage = "https://www.igorski.nl/download/homecorrupter";
  };
})
