{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gnumake,
  perl,
}:

stdenvNoCC.mkDerivation {
  pname = "xcompose";
  version = "unstable-2026-06-17";

  src = fetchFromGitHub {
    owner = "kragen";
    repo = "xcompose";
    rev = "2131a4712910a0df23be46bdfae5ff812dd295a9";
    sha256 = "sha256-xFprIrOgvniglZpjCOYPwo693G8fpFQ2eHvPeFeOocM=";
  };

  nativeBuildInputs = [
    gnumake
    perl
  ];

  preBuild = ''
    substituteInPlace emojitrans2.pl \
      --replace "#!/usr/bin/env -S perl -p" "#!/usr/bin/perl -p"
    patchShebangs $(find . -executable -type f)
  '';

  installPhase = ''
    install -m 444 -D dotXCompose $out/dotXCompose
    install -m 444 -D frakturcompose $out/frakturcompose
    install -m 444 -D emoji.compose $out/emoji.compose
    install -m 444 -D modletters.compose $out/modletters.compose
    install -m 444 -D parens.compose $out/parens.compose
    install -m 444 -D maths.compose $out/maths.compose
    install -m 444 -D tags.compose $out/tags.compose
  '';

  meta = with lib; {
    description = "for sharing .XCompose keybindings";
    homepage = "https://github.com/kragen/xcompose";
    license = licenses.unfree;
    maintainers = with maintainers; [ lunik1 ];
    platforms = platforms.all;
  };
}
