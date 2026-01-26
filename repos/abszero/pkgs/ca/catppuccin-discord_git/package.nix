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
  version = "0-unstable-2026-01-26";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "discord";
    rev = "f235754322320211a8646d963466fac402e5c297";
    hash = "sha256-7v1Hu6QofOyFOGnHeqHFK0JsxUxdJ9uTjI7nM7mdTsg=";
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
