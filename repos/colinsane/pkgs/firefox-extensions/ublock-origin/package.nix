{
  addon-git-updater,
  concatTextFile,
  fetchurl,
  jq,
  runCommand,
  stdenvNoCC,
  unzip,
  wrapFirefoxAddonsHook,
  writers,
  zip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ublock-origin";
  version = "1.64.0";
  src = fetchurl {
    # N.B.: the release process seems to be to first release an unsigned .xpi,
    #       then sign it a few days later,
    #       and then REMOVE THE UNSIGNED RELEASE.
    #       therefore, only grab signed releases, to avoid having the artifact disappear out from under us :(
    # url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.firefox.xpi";
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.firefox.signed.xpi";
    hash = "sha256-ueHIaL0awd78q/LgF3bRqQ7/ujSwf+aiE1DUXwIuDp8=";
    name = "uBlock0_${version}.firefox.signed.zip";
  };
  # .zip file has everything in the top-level; stdenv needs it to be extracted into a subdir:
  sourceRoot = ".";
  preUnpack = ''
    mkdir src && cd src
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    zip -r -FS $out/$extid.xpi .
    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip  # for unpackPhase
    wrapFirefoxAddonsHook
    zip
  ];

  extid = "uBlock0@raymondhill.net";

  passthru = {
    updateScript = addon-git-updater;

    # `makeConfig` produces a .json file meant to go at
    # ~/.mozilla/managed-storage/uBlock0@raymondhill.net.json
    # this is not formally documented anywhere, but is referenced from a few places:
    # - <https://github.com/gorhill/uBlock/issues/2986#issuecomment-364035002>
    # - <https://www.reddit.com/r/uBlockOrigin/comments/16bzb11/configuring_ublock_origin_for_nix_users_just_in/>
    # - <https://www.reddit.com/r/sysadmin/comments/8lwmbo/guide_deploying_ublock_origin_with_preset/>
    #
    # a large part of why i do this is to configure the filters statically,
    # so that they don't have to be fetched on every boot.
    makeConfig = { filterFiles }: let
      mergedFilters = concatTextFile {
        name = "ublock-origin-filters-merged.txt";
        files = filterFiles;
        destination = "/share/filters/ublock-origin-filters-merged.txt";
      };
      baseConfig = writers.writeJSON "uBlock0@raymondhill.net.json" {
        name = "uBlock0@raymondhill.net";
        description = "ignored";
        type = "storage";
        data = {
          adminSettings = {
            #^ adminSettings dictionary uses the same schema as the "backup to file" option in settings.
            userSettings = {
              # default settings are found: <repo:gorhill/uBlock:src/js/background.js>  (userSettingsDefault)
              advancedUserEnabled = true;
              autoUpdate = false;
              # don't block page load when waiting for filter load
              suspendUntilListsAreLoaded = false;
            };
            selectedFilterLists = [ "user-filters" ];
            # there's an array version of this field too, if preferable
            filters = "";  #< WILL BE SUBSTITUTED DURING BUILD
          };
        };
      };
    in runCommand "ublock-origin-config" {
      preferLocalBuild = true;
      nativeBuildInputs = [ jq ];
    } ''
      cat ${baseConfig} | jq 'setpath(["data", "adminSettings", "userFilters"]; $filterText)' --rawfile filterText ${mergedFilters}/share/filters/ublock-origin-filters-merged.txt > $out
    '';
  };
}
