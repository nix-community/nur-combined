{ lib, stdenv, fetchFromGitHub, config ? null, dataDir ? "/var/lib/freshrss" }:

stdenv.mkDerivation rec {
  name = "freshrss-${version}";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "FreshRSS";
    repo = "FreshRSS";
    rev = "${version}";
    sha256 = "1gnx9bkqcmfbr632ilyr78wwrs7vg9s9iqmpf45m2zwyclnz87ya";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir $out
    cp -ra $src/. $out/
    find $out -type d -exec chmod 0755 {} \;
    find $out -type f -exec chmod 0644 {} \;
    mv $out/data $out/data.orig
    ln -s "${dataDir}" $out/data
  '';

  meta = with stdenv.lib; {
    description = "a self-hosted RSS feed aggregator like Leed or Kriss Feed";
    license = licenses.agpl3;
    homepage = https://www.freshrss.org/;
    platforms = platforms.all;
    maintainers = with stdenv.lib.maintainers; [ tokudan ];
  };
}
