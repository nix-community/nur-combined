{stdenv, fetchFromGitHub, lib}:
stdenv.mkDerivation {
  pname = "FuzzyMarks";
  version = "0.0.1";
  src = fetchFromGitHub {
    owner = "novel2430";
    repo = "FuzzyMarks";
    rev = "667970f3e3cf3a3ea857a0d7d2ea714476c5c68f";
    sha256 = "sha256-xOqHJIPBEyJHQuyrtouOQbzFqSPMsdaSJIm+obLpDRQ=";
  };
  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 bookmarks-selector.py $out/bin/fuzzyMarks
    install -Dm755 bookmarks-editor.py $out/bin/fuzzyMarks-editor
  '';
  meta = with lib; {
    description = "A simple and user-friendly bookmark manager with a fuzzy finder interface! Add, remove, or modify bookmarks and folders using the command-line editor.";
    homepage = "https://github.com/novel2430/FuzzyMarks";
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
    license = with licenses; [ mit ];
  };
}
