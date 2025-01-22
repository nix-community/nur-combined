{ lib
, stdenv
, fetchFromGitHub
, qrencode
, zbar
, imagemagick
}:

stdenv.mkDerivation rec {
  pname = "paperify";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "alisinabh";
    repo = "paperify";
    rev = "v${version}";
    hash = "sha256-0E7wEg1K+9ccvj+ncz2a9nNZwlN8RxgpGBY/czy7WPw=";
  };

  buildPhase = ''
     runHook preBuild

     substituteInPlace paperify.sh \
       --replace ' qrencode ' ' ${lib.getBin qrencode}/bin/qrencode ' \
       --replace ' convert ' ' ${lib.getBin imagemagick}/bin/convert '
     substituteInPlace digitallify.sh \
       --replace ' zbarimg ' ' ${lib.getBin zbar}/bin/zbarimg '

     runHook postBuild
  '';

  installPhase = ''
     runHook preInstall

     install -Dm755 paperify.sh $out/bin/paperify
     install -Dm755 digitallify.sh $out/bin/digitallify

     runHook postInstall
  '';

  meta = with lib; {
    description = "Backup data using qrcode. Minimal PaperBackup solution for small to medium sized files using QR-Codes";
    homepage = "https://github.com/alisinabh/paperify";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ nagy ];
    mainProgram = "paperify";
    platforms = platforms.all;
  };
}
