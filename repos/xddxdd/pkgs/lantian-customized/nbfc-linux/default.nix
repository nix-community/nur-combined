{ stdenv
, fetchFromGitHub
, lib
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "nbfc-linux";
  version = "32a49117ca3ff17d7681713a8dc8812323142dcb";
  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "nbfc-linux";
    rev = version;
    sha256 = "sha256-jKuCBKUm32ulgH0+/be2s+CgeBqTww+4K3RETFFCCOc=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "NoteBook FanControl ported to Linux (with Lan Tian's modifications)";
    homepage = "https://github.com/xddxdd/nbfc-linux";
    license = licenses.gpl3;
  };
}
