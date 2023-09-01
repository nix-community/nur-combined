{ lib
, stdenv
, fetchFromGitHub
, jdupes
, nix-update-script
}:

stdenv.mkDerivation {
  pname = "gruvbox-plus-icons";
  version = "unstable-2023-08-31";

  src = fetchFromGitHub {
    owner = "SylEleuth";
    repo = "gruvbox-plus-icon-pack";
    rev = "8a1fc942478b6542312d553e1fdd77ef5730dd54";
    hash = "sha256-5zJUd4ZYY8oz8eXiSHfRyXovlmSbUWUXdFg50m7VHy0=";
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