{ lib
, stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "ttf-wps-fonts";
  version = "unstable-2017-08-16";

  src = fetchFromGitHub {
    owner = "BannedPatriot";
    repo = pname;
    rev = "b3e935355afcfb5240bac5a99707ffecc35772a2";
    sha256 = "sha256-oRVREnE3qsk4gl1W0yFC11bHr+cmuOJe9Ah+0Csplq8=";
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

