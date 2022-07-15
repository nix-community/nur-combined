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
  in
    stdenvNoCC.mkDerivation {
      name = "${app.name}-langpack-${mozLanguage}-${langpack.version}";
      src = fetchurl {
        name = "${app.name}-langpack-${mozLanguage}-${langpack.version}-${app.arch}.xpi";
        inherit (langpack) url hash;
      };

      meta =
        filterAttrs (n: _: elem n ["homepage" "license" "platforms" "badPlatforms"]) mozApp.meta
        // {
          description = "${app.fullName} language pack for the '${mozLanguage}' language.";
        };

      preferLocalBuild = true;
      # Do not use `allowSubstitutes = false;`: https://github.com/NixOS/nix/issues/4442

      buildCommand = ''
        dst="$out/share/mozilla/extensions/${app.extensionDir}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    }
