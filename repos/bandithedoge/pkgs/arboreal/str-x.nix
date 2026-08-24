{ arboreal, fetchFromGitHub }:
arboreal.mkArboreal (finalAttrs: {
  pname = "str-x";
  version = "1.2.1";
  src = fetchFromGitHub {
    owner = "ArborealAudio";
    repo = "STR-X";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fj/XJUUSRxLa9q9wMi7aOtHQNUFchAHepENJYRIGF1Y=";
    fetchSubmodules = true;
  };

  meta = {
    homepage = "https://arborealaudio.com/plugins/str-x";
    description = "Not your grandpa's guitar amp";
  };
})
