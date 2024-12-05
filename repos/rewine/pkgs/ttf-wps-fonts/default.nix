{ lib
, stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "ttf-wps-fonts";
  version = "0-unstable-2024-10-29";

  src = fetchFromGitHub {
    owner = "BannedPatriot";
    repo = pname;
    rev = "8c980c24289cb08e03f72915970ce1bd6767e45a";
    sha256 = "sha256-x+grMnpEGLkrGVud0XXE8Wh6KT5DoqE6OHR+TS6TagI=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -D *.{ttf,TTF} $out/share/fonts/truetype/

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/BannedPatriot/ttf-wps-fonts";
    description = "Symbol fonts required by wps-office";
    longDescription = ''
      These are the symbol fonts required by wps-office.
      They are used to display math formulas.
      We have collected the fonts here to make things easier.
    '';
    license = licenses.unfree;
    platforms = platforms.all;
  };
}

