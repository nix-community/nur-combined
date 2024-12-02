{stdenv, fetchFromGitHub, lib}:
stdenv.mkDerivation {
  pname = "FuzzyMarks";
  version = "0.0.3";
  src = fetchFromGitHub {
    owner = "novel2430";
    repo = "FuzzyMarks";
    rev = "dfb56ad7b29338193c55910b0c687aeeccea62fe";
    sha256 = "sha256-utCzyuCXER4RVN9Q7cPaNTUDcGA46W/nSxiMU3ZkDyI=";
  };
  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 bookmarks-selector.py $out/bin/fuzzyMarks
    install -Dm755 bookmarks-editor.py $out/bin/fuzzyMarks-editor
    install -Dm755 bookmarks-translate.py $out/bin/fuzzyMarks-translate
  '';
  meta = with lib; {
    description = "A simple and user-friendly bookmark manager with a fuzzy finder interface! Add, remove, or modify bookmarks and folders using the command-line editor.";
    homepage = "https://github.com/novel2430/FuzzyMarks";
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
    license = with licenses; [ mit ];
  };
}
