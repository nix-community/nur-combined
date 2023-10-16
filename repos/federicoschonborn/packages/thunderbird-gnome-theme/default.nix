{ lib
, stdenvNoCC
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation {
  pname = "thunderbird-gnome-theme";
  version = "unstable-2023-08-02";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "thunderbird-gnome-theme";
    rev = "e38a25e37276778fb10337bc95cef764da91c8fc";
    hash = "sha256-oAhsFGnYaq9B7uQYqNmWupEmF3+dakcnZWhV7NJp/WE=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/
    cp -r $src/* $out/

    runHook postInstall
  '';

  meta = {
    description = "A GNOME theme for Thunderbird";
    homepage = "https://github.com/rafaelmardojai/thunderbird-gnome-theme";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
