# Build the language pack for the specified app and language.
#
# This package requires lots of parameters; see the `makeMozillaLangpack`
# function in `./packages.nix` for a more convenient way to use it.
#
let
  functions = import ./functions.nix;
in
  {
    # Custom parameters.
    mozApp,
    mozLanguage,
    mozAppName ? mozApp.pname,
    mozAppVersion ? lib.getVersion mozApp,
    mozSupportedApps,
    mozPlatforms,
    mozLangpackSources,
    # Various components from Nixpkgs.
    lib,
    callPackage,
    fetchurl,
    stdenvNoCC,
  }: let
    inherit (builtins) elem;
    inherit (lib) filterAttrs;

    app = functions.getAppInfo {
      inherit lib mozSupportedApps mozPlatforms mozApp mozAppName mozAppVersion;
    };
    langpack = mozLangpackSources.${app.name}.${app.majorKey}.${app.arch}.${mozLanguage};
    addonId = "langpack-${mozLanguage}@${app.addonIdSuffix}";
    installFilePath = "share/mozilla/extensions/${app.extensionDir}/${addonId}.xpi";
    narHash = langpack.narHash.${installFilePath} or null;
    name = "${app.name}-langpack-${mozLanguage}-${langpack.version}";
    homepage = let
      matchResult = builtins.match "([^?#]*/)[^/?#]*([?#].*)?" langpack.url;
    in
      if matchResult == null
      then null
      else builtins.head matchResult;
    meta =
      filterAttrs (n: _: elem n ["homepage" "license" "platforms" "badPlatforms"]) mozApp.meta
      // {
        description = "${app.fullName} language pack for the '${mozLanguage}' language.";
      }
      // lib.optionalAttrs (homepage != null) {
        inherit homepage;
      };
  in
    if narHash != null
    then
      fetchurl {
        inherit name meta;
        inherit (langpack) url;
        hash = narHash;
        recursiveHash = true;
        downloadToTemp = true;
        postFetch = ''
          install -v -m444 -D "$downloadedFile" "$out/${installFilePath}"
          rm "$downloadedFile"
        '';
      }
    else
      stdenvNoCC.mkDerivation {
        inherit name meta;
        src = fetchurl {
          name = "${app.name}-langpack-${mozLanguage}-${langpack.version}-${app.arch}.xpi";
          inherit (langpack) url hash;
        };

        preferLocalBuild = true;
        # Do not use `allowSubstitutes = false;`: https://github.com/NixOS/nix/issues/4442

        buildCommand = ''
          install -v -m444 -D "$src" "$out/${installFilePath}"
        '';
      }
