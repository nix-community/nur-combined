{
  default = "MetaGer";
  enginesSet = {
    # TODO: Separate this into categories
    # Search engines
    "Searx (searx.work)" =
      let
        url = "https://searx.work";
      in {
        iconURL = "${url}/static/themes/simple/img/favicon.png";
        urls = [{
          template = "${url}/search";
          params = [
            { name = "q"; value = "{searchTerms}"; }
            { name = "safesearch"; value = "0"; }
            { name = "categories"; value = "general"; }
          ];
        }];
        definedAliases = [ "@searx" ];
      };
    "MetaGer" =
      let
        url = "https://metager.org";
      in {
        iconURL = "${url}/favicon.ico";
        urls = [{
          template = "${url}/meta/meta.ger3";
          params = [
            { name = "eingabe"; value = "{searchTerms}"; }
            { name = "focus"; value = "web"; }
          ];
        }];
        definedAliases = [ "@metager" ];
      };
    "Bing".metaData.hidden = true;
    "Google".metaData.alias = "@g";
    "DuckDuckGo".metaData.alias = "@ddg";
    # Nix/NixOS
    "nixpkgs - Packages" = {
      iconURL = "https://nixos.org/favicon.png";
      urls = [{
        template = "https://search.nixos.org/packages";
        params = [
          # TODO: Consider channels
          { name = "type"; value = "packages"; }
          { name = "query"; value = "{searchTerms}"; }
        ];
      }];
      definedAliases = [ "@nixpkgs" ];
    };
    "nixpkgs - Options" = {
      iconURL = "https://nixos.org/favicon.png";
      urls = [{
        template = "https://search.nixos.org/options";
        params = [
          # TODO: Consider channels
          { name = "type"; value = "packages"; }
          { name = "query"; value = "{searchTerms}"; }
        ];
      }];
      definedAliases = [ "@nixopts" ];
    };
    "nixpkgs - Revisions" = {
      iconURL = "https://nixos.org/favicon.png";
      urls = [{
        template = "https://lazamar.co.uk/nix-versions";
        params = [
          # TODO: Consider channels
          { name = "channel"; value = "nixpkgs-unstable"; }
          { name = "package"; value = "{searchTerms}"; }
        ];
      }];
      definedAliases = [ "@nixrev" ];
    };
    "nixpkgs - PR Tracker" = {
      iconURL = "https://nixos.org/favicon.png";
      urls = [{ template = "https:///nixpk.gs/pr-tracker.html?pr={searchTerms}"; }];
      definedAliases = [ "@nixpr" ];
    };
    # Code related
    "Sourcegraph" =
      let
        url = "https://sourcegraph.com";
      in {
        iconURL = "${url}/.assets/img/sourcegraph-mark.svg?v2";
        urls = [{
          template = "${url}/search";
          params = [
            { name = "patternType"; value = "standard"; }
            { name = "groupBy"; value = "repo"; }
            { name = "q"; value = "context%3Aglobal+{searchTerms}"; }
          ];
        }];
        definedAliases = [ "@source" "@sourcegraph" ];
      };
    "GitHub" =
      let
        url = "https://github.com";
      in {
        iconURL = "${url}/favicon.ico";
        urls = [{ template = "${url}/search?q={searchTerms}"; }];
        definedAliases = [ "@gh" "@github" ];
      };
    # Music/Videos
    "Bandcamp" = {
      iconURL = "https://s4.bcbits.com/img/favicon/favicon-32x32.png";
      urls = [{ template = "https://bandcamp.com/search?q={searchTerms}"; }];
      definedAliases = [ "@band" "@bandcamp" ];
    };
    "Piped (piped.mha.fi)" =
      let
        url = "https://piped.mha.fi";
      in {
        iconURL = "${url}/favicon.ico";
        urls = [{ template = "${url}/results?search_query={searchTerms}"; }];
        definedAliases = [ "@piped" ];
      };
    # Maps
    "Google Maps" =
      let
        url = "https://maps.google.com";
      in {
        iconURL = "${url}/favicon.ico";
        urls = [{ template = "${url}/?&q={searchTerms}"; }];
        definedAliases = [ "@maps" "@gmaps" "@googlemaps" ];
      };
    # Dictionaries
    "Merriam-Webster" =
      let
        url = "https://www.merriam-webster.com";
      in {
        iconURL = "${url}/favicon.ico";
        urls = [{ template = "${url}/dictionary/{searchTerms}"; }];
        definedAliases = [ "@mw" "@merriamwebster" "@en" "@english" ];
      };
    "Priberam" =
      let
        url = "https://dicionario.priberam.org";
      in {
        iconURL = "${url}/favicon.ico";
        urls = [{ template = "${url}/{searchTerms}"; }];
        definedAliases = [ "@priberam" "@pt" "@portugues" ];
      };
    "RAE" =
      let
        url = "https://dle.rae.es";
      in {
        iconURL = "${url}/favicon.ico";
        urls = [{ template = "${url}/{searchTerms}"; }];
        definedAliases = [ "@rae" "@es" "@espanol" ];
      };
    # Package Managers
    "Crates (Rust)" =
      let
        url = "https://crates.io";
      in {
        iconURL = "${url}/favicon.ico";
        urls = [{ template = "${url}/search?q={searchTerms}"; }];
        definedAliases = [ "@crates" ];
      };
    "PyPI (Python)" =
      let
        url = "https://pypi.org";
      in {
        iconURL = "${url}/static/images/favicon.35549fe8.ico";
        urls = [{ template = "${url}/search/?q={searchTerms}"; }];
        definedAliases = [ "@pypi" ];
      };
    # Other
    "Metal Archives - Bands" =
      let
        url = "https://www.metal-archives.com";
      in {
        iconURL = "${url}/favicon.ico";
        urls = [{
          template = "${url}/search?";
          params = [
            { name = "type"; value = "band_name"; }
            { name = "searchString"; value = "{searchTerms}"; }
          ];
        }];
        definedAliases = [ "@metal" "@metalarchives" ];
      };
    "Amazon.com".metaData.hidden = true;
  };
}
