{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  nodejs,
  themes0 ? [ ],
}:

let
  inherit (builtins) length;
  inherit (lib) head concatStringsSep;

  matchTheme =
    if themes0 == [ ] then
      "*"
    else if length themes0 == 1 then
      head themes0
    else
      "{${concatStringsSep "," themes0}}";
in

stdenv.mkDerivation (final: {
  pname = "catppuccin-discord";
  version = "0-unstable-2026-02-07";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "discord";
    rev = "b9b5547f0b32296d2389716ef606de87b3c1e7c7";
    hash = "sha256-rxvHIifq5CYIBPwFA2SpOrWT+sG/z0ItXT3sx2wbEqg=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = final.src + "/yarn.lock";
    hash = "sha256-BhE3aKyA/LBErjWx+lbEVb/CIXhqHkXbV+9U2djIBhs=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/catppuccin-discord"
    cp dist/dist/catppuccin-${matchTheme}.theme.css "$out/share/catppuccin-discord"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Soothing pastel theme for Discord";
    homepage = "https://github.com/catppuccin/discord";
    license = licenses.mit;
    maintainers = with maintainers; [ weathercold ];
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
})
