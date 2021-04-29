{ lib, fetchFromGitHub, stdenv, writeText, ... }:

stdenv.mkDerivation rec {
  pname = "freshrss";
  version = "1.18.0";

  src = fetchFromGitHub {
    owner = "FreshRSS";
    repo = "FreshRSS";
    rev = version;
    sha256 = "1f0v7wwxx0a7ahf9hdcqcnrvwxihxqg7b38d9ivwb2db9bs9d4d0";
  };

  phpConfig = writeText "constants.local.php" ''
    <?php
      safe_define('DATA_PATH', getenv('FRESHRSS_DATA'));
      safe_define('THIRDPARTY_EXTENSIONS_PATH', getenv('FRESHRSS_EXTENSIONS'));
    ?>
  '';

  installPhase = ''
    mkdir $out/
    cp -r ./* $out
    cp ${phpConfig} $out/constants.local.php
  '';

  meta = with lib; {
    description = "Self-hosted RSS feed aggregator";
    homepage = "https://freshrss.org/";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ dawidsowa ];
    platforms = platforms.all;
  };
}
