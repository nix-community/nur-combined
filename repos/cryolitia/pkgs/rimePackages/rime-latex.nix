{ maintainers
, stdenvNoCC
, lib
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation {

  pname = "rime-latex";
  version = "unstabl-20230703";

  src = fetchFromGitHub {
    owner = "shenlebantongying";
    repo = "rime_latex";
    rev = "fb32dc50c19b3913023199ceaae22168cd5a7db7";
    sha256 = "sha256-ZSnfkHc0yyXZTVZBjPI8mcjR9CRyKy8qpQFww2VF3QI=";
  };

  installPhase = ''
    install -Dm644 *.yaml -t "$out/share/rime-data/"
  '';

  meta = with lib; {
    homepage = "https://github.com/shenlebantongying/rime_latex";
    description = "Typing LaTeX math symbols in RIME.";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Cryolitia ];
  };
}
