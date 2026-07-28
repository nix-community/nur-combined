{
  lib,
  writers,
  curl,
  gnugrep,
  fetchFirefoxAddon,
  ...
}:
let
  addonsInfo = {
    darkreader = {
      fixedExtid = "addon@darkreader.org";
      fileId = 4665768;
      version = "4.9.119";
      hash = "sha256-JhpCLy/Pg+4yCseigJ2Sa4Y3+63s6KV1i4Jb0GApRL4=";
    };
    steamdb = {
      fixedExtid = "firefox-extension@steamdb.info";
      amoId = "steam-database";
      fileId = 4657779;
      version = "4.32";
      hash = "sha256-ibK4EuD0tY00qvLtj6mhhoQtbJ3wY2Q3+Ur/TS4JgEw=";
    };
    betterttv = {
      fixedExtid = "firefox@betterttv.net";
      fileId = 4660244;
      version = "7.6.18";
      hash = "sha256-gAoJAZUjmN1IbJsJuLzh04Ti0YyoxEW5DgsbfiF4Tdo=";
    };
    consent-o-matic = {
      fixedExtid = "gdpr@cavi.au.dk";
      fileId = 4515369;
      version = "1.1.5";
      hash = "sha256-ohGavDKWONbnrxq05VSKNIRl4C7sEd4I3uCvhJGZI9w=";
    };
    decentraleyes = {
      fixedExtid = "jid1-BoFifL9Vbdl2zQ@jetpack";
      fileId = 4392113;
      version = "3.0.0";
      hash = "sha256-by7+2QaWrH+Mp++4qzCP6zvfGCNQs6z99AUMCcwC8RM=";
    };
    youtube-unhook = {
      fixedExtid = "myallychou@gmail.com";
      amoId = "youtube-recommended-videos";
      fileId = 4263531;
      version = "1.6.7";
      hash = "sha256-u21ouN9IyOzkTkFSeDz+QBp9psJ1F2Nmsvqp6nh0DRU=";
    };
    sponsorblock = {
      fixedExtid = "sponsorBlocker@ajay.app";
      fileId = 4644570;
      version = "6.1.2";
      hash = "sha256-WY9myetrurK9X4c3a2MqWGD0QtNpTiM2EPWzf4tuPxA=";
    };
    ublock-origin = {
      fixedExtid = "uBlock0@raymondhill.net";
      fileId = 4629131;
      version = "1.68.0";
      hash = "sha256-XK9KvaSUAYhBIioSFWkZu92MrYKng8OMNrIt1kJwQxU=";
    };
    bitwarden = {
      fixedExtid = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
      amoId = "bitwarden-password-manager";
      fileId = 4664623;
      version = "2025.12.1";
      hash = "sha256-p6Ej7uTkD92K98DGckNzHdzDeuFJjPKCiZX0kFYAxR8=";
    };
    clearurls = {
      fixedExtid = "{74145f27-f039-47ce-a470-a662b129930a}";
      fileId = 4432106;
      version = "1.27.3";
      hash = "sha256-VJJrbkJ01ZNaX8DapjIPHTcePS8aWHdGfKOrIqZcTyA=";
    };
  };
  addonsDerivs = lib.mapAttrs (
    name:
    {
      fixedExtid,
      hash ? "",
      amoId ? name,
      version ? "",
      fileId ? 0,
    }:
    (fetchFirefoxAddon {
      inherit name fixedExtid hash;
      url = "https://addons.mozilla.org/firefox/downloads/file/${toString fileId}/${
        lib.replaceStrings [ "-" ] [ "_" ] amoId
      }-${version}.xpi";
    }).overrideAttrs
      {
        inherit version;
        passthru = rec {
          latestUrl = "https://addons.mozilla.org/firefox/downloads/latest/${amoId}/latest.xpi";
          getUrl = writers.writeBashBin "get-${name}-url" { } ''
            ${lib.getExe curl} -s -D - -o /dev/null ${lib.escapeShellArg latestUrl} | ${lib.getExe gnugrep} '^location: '
          '';
        };
      }
  ) addonsInfo;
in
lib.recurseIntoAttrs addonsDerivs
