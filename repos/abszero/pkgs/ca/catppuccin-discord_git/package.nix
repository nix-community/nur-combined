{
  stdenv,
  lib,
  fetchFromGitHub,
  mkYarnModules,
  nodejs,
  yarn,
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
  version = "0-unstable-2026-01-10";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "discord";
    rev = "0fcfe2e15ed91f8c5f1f3c6855f3b2024f78d86c";
    hash = "sha256-ExRNnxvG2PSGmpuaPxzCKL6GK6ETs7Gq4Roa74HXp+s=";
  };

  nodeModules = mkYarnModules {
    pname = "${final.pname}-node-modules";
    version = final.version;

    packageJSON = final.src + "/package.json";
    yarnLock = final.src + "/yarn.lock";
  };

  nativeBuildInputs = [
    nodejs
    yarn
  ];

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    ln -s "$nodeModules/node_modules" node_modules
    yarn --offline release

    runHook postBuild
  '';

  # Stop yarn from trying to build a binary in distPhase
  distPhase = "true";

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
