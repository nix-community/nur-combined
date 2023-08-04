{
  lib,
  stdenv,
  cabextract,
  fetchzip,
}:
stdenv.mkDerivation rec {
  pname = "mscore-ttf";
  version = "final";

  src = fetchzip {
    url = "https://www.freedesktop.org/software/fontconfig/webfonts/webfonts.tar.gz";
    sha256 = "sha256-fZxwHn1CsTvUyg/h7hdUFFc5Mhh36Oj17c5mrpmKKvk=";
  };

  nativeBuildInputs = [
    cabextract
  ];

  buildPhase = ''
    cabextract *.exe -L
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = {
    homepage = "https://learn.microsoft.com/en-us/typography/";
    description = "Microsofts core fonts for the web";
    #license = TODO: Microsoft Software License Terms
    platforms = lib.platforms.all;
    maintainers = [];
  };
}
