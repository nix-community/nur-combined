{ lib
, stdenv
, fetchFromGitHub
, jdupes
, nix-update-script
}:

stdenv.mkDerivation {
  pname = "gruvbox-plus-icons";
  version = "unstable-2023-09-22";

  src = fetchFromGitHub {
    owner = "SylEleuth";
    repo = "gruvbox-plus-icon-pack";
    rev = "2475e21abf11f6ad0857d26b5b6adbf9fdea7b73";
    hash = "sha256-0vR5fpLz0dT5E1ujGy4TTlkKDGu2nK0EXPrMwPmU1HI=";
  };

  dontBuild = true;

  nativeBuildInputs = [ jdupes ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons
    cp -r Gruvbox* $out/share/icons

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = with lib; {
    description = "Gruvbox Plus icon pack for Linux desktops based on Gruvbox color theme";
    homepage = "https://github.com/SylEleuth/gruvbox-plus-icon-pack";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}