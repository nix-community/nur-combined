{ lib
, stdenvNoCC
, fetchFromGitHub
, unstableGitUpdater
}:

stdenvNoCC.mkDerivation {
  pname = "thunderbird-gnome-theme";
  version = "unstable-2023-11-06";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "thunderbird-gnome-theme";
    rev = "a899ca12204d19f4834fbd092aa5bb05dc4bd127";
    hash = "sha256-3TQYBJAeQ2fPFxQnD5iKRKKWFlN3GJhz1EkdwE+4m0k=";
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
