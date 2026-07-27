{ stdenv, fetchzip, ... }:
stdenv.mkDerivation {
  name = "note";
  version = "2024-04-15";

  src = fetchzip {
    url = "https://github.com/lpaulsen93/dokuwiki_note/archive/f41cd6594f563b198bd113a39a7e17667c3e3ceb.zip";
    hash = "sha256-qEoRvPQiRSZZTqOhYOw+CEro0PSNWljqkwqcL1ZA7Os=";
  };
  installPhase = "mkdir -p $out; cp -R * $out/";
}
