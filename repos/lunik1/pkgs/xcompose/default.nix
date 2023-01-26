{ lib
, stdenvNoCC
, fetchFromGitHub
, gnumake
, perl
}:

stdenvNoCC.mkDerivation rec {
  pname = "xcompose";
  version = "2022-09-15";

  src = fetchFromGitHub {
    owner = "kragen";
    repo = "xcompose";
    rev = "cd8d3e622f547ec9f83d7f64f51d4a27ee812681";
    sha256 = "sha256-fkl2lDv/DdrqPjVsEUKSRD3BNGwTjTsA0ovI8akFI6U=";
  };

  nativeBuildInputs = [ gnumake perl ];

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
