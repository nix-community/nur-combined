{stdenv, fetchFromGitHub, lib}:
stdenv.mkDerivation {
  pname = "FuzzyMarks";
  version = "0.0.2";
  src = fetchFromGitHub {
    owner = "novel2430";
    repo = "FuzzyMarks";
    rev = "ec4946b65f09162075f5fd1d6a0fb63f7329b665";
    sha256 = "sha256-kh7n8PwZxqpmC/MNkg/QyL8mcbOHBRioYk1ZuaBO0L0=";
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
