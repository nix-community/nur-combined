{ lib
, stdenvNoCC
, fetchFromGitHub
, unstableGitUpdater
}:

stdenvNoCC.mkDerivation {
  pname = "thunderbird-gnome-theme";
  version = "unstable-2023-09-23";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "thunderbird-gnome-theme";
    rev = "99620f1353689c9ac0a3fc389306faf2b9137fa8";
    hash = "sha256-lfQ4M4Jm/bxig3koPRAoSaS4bZScqkvtS+2vKDScNeg=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/
    cp -r $src/* $out/

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "A GNOME theme for Thunderbird";
    homepage = "https://github.com/rafaelmardojai/thunderbird-gnome-theme";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
