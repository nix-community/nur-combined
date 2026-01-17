{
  lib,
  callPackage,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix { },
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:
let
  xpifile = buildNpmPackage (finalAttrs: {
    pname = "steam-database";
    version = "4.32";

    src = fetchFromGitHub {
      owner = "SteamDatabase";
      repo = "BrowserExtension";
      rev = "v${finalAttrs.version}";
      hash = "sha256-2HMoklpqNWO0xmX0CbkMfWz0FqS45NP7LJ6IRnhZIjQ=";
    };

    npmDepsHash = "sha256-lEzNh72k6kAb5N1Xr5ri9fOGfIEcJhrJJvxyc1B5D4E=";

    installPhase = ''
      runHook preInstall

      cp steamdb_ext_${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}_firefox.zip $out

      runHook postInstall
    '';

    passthru.updateScript = nix-update-script { };
  });
in
buildFirefoxXpiAddon {
  inherit (xpifile) pname version;
  addonId = "firefox-extension@steamdb.info";

  src = xpifile;

  meta = {
    description = "SteamDB's extension for Steam websites";
    homepage = "https://github.com/SteamDatabase/BrowserExtension";
    maintainers = with lib.maintainers; [ dtomvan ];
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
    mozPermissions = [
      "storage"
      "https://steamdb.info/*"
      "https://store.steampowered.com/*"
      "https://steamcommunity.com/*"
      "https://store.steampowered.com/app/*"
      "https://store.steampowered.com/news/app/*"
      "https://store.steampowered.com/account/licenses*"
      "https://store.steampowered.com/account/registerkey*"
      "https://store.steampowered.com/sub/*"
      "https://store.steampowered.com/bundle/*"
      "https://store.steampowered.com/widget/*"
      "https://store.steampowered.com/app/*/agecheck"
      "https://store.steampowered.com/agecheck/*"
      "https://store.steampowered.com/explore*"
      "https://steamcommunity.com/app/*"
      "https://steamcommunity.com/sharedfiles/filedetails*"
      "https://steamcommunity.com/workshop/filedetails*"
      "https://steamcommunity.com/workshop/browse*"
      "https://steamcommunity.com/workshop/discussions*"
      "https://steamcommunity.com/id/*"
      "https://steamcommunity.com/profiles/*"
      "https://steamcommunity.com/id/*/inventory*"
      "https://steamcommunity.com/profiles/*/inventory*"
      "https://steamcommunity.com/id/*/stats*"
      "https://steamcommunity.com/profiles/*/stats*"
      "https://steamcommunity.com/id/*/stats/CSGO*"
      "https://steamcommunity.com/profiles/*/stats/CSGO*"
      "https://steamcommunity.com/stats/*/achievements*"
      "https://steamcommunity.com/tradeoffer/*"
      "https://steamcommunity.com/id/*/recommended/*"
      "https://steamcommunity.com/profiles/*/recommended/*"
      "https://steamcommunity.com/id/*/badges*"
      "https://steamcommunity.com/profiles/*/badges*"
      "https://steamcommunity.com/id/*/gamecards/*"
      "https://steamcommunity.com/profiles/*/gamecards/*"
      "https://steamcommunity.com/market/multibuy*"
      "https://steamcommunity.com/market/*"
      "https://steamcommunity.com/games/*"
      "https://steamcommunity.com/sharedfiles/*"
      "https://steamcommunity.com/workshop/*"
    ];
  };
}
