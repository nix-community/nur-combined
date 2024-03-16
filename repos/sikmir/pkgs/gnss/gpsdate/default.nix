{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
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

  meta = with lib; {
    description = "Simple tool for fetching date and time from a GPS receiver and saving it as a local time";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    mainProgram = "gpsdate";
  };
})
