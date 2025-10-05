{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "gpsdate";
  version = "0-unstable-2019-12-02";

  src = fetchFromGitHub {
    owner = "adamheinrich";
    repo = "gpsdate";
    rev = "3e48ab58b73485d08e9f4d48054d5e7379e05805";
    hash = "sha256-h/XxQjjelUPYhIuJybZZm/bL07nj242utmYNCwTNw9w=";
  };

  patches = [ ./clock_settime.patch ];

  installPhase = ''
    install -Dm755 gpsdate -t $out/bin
  '';

  meta = {
    description = "Simple tool for fetching date and time from a GPS receiver and saving it as a local time";
    homepage = "https://github.com/adamheinrich/gpsdate";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "gpsdate";
  };
}
