{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "font-office";
  version = "unstable-2026-04-27";

  src = fetchFromGitHub {
    owner = "chillcicada";
    repo = "fonts";
    rev = "faa446035b205dcf229f6834c1e6895b9da05d95";
    sha256 = "sha256-OLEQFdwJhv10wrWIURtW7ll97gQUJg0dkPJUpVSeeKs=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -D *.ttf $out/share/fonts/truetype/
    install -D *.ttc $out/share/fonts/

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/chillcicada/fonts/tree/office";
    description = "Office fonts";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
