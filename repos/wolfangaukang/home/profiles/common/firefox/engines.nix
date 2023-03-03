{
  default = "MetaGer";
  enginesSet = {
    # TODO: Separate this into categories
    "Searx (searx.work)" = {
      urls = [{
        template = "https://searx.work/search";
        params = [
          { name = "q"; value = "{searchTerms}"; }
          { name = "safesearch"; value = "0"; }
          { name = "categories"; value = "general"; }
        ];
      }];
      definedAliases = [ "@searx" ];
    };
    "MetaGer" = {
      urls = [{
        template = "https://metager.org/meta/meta.ger3";
        params = [
          { name = "eingabe"; value = "{searchTerms}"; }
          { name = "focus"; value = "web"; }
        ];
      }];
      definedAliases = [ "@metager" ];
    };
    "nixpkgs - Packages" = {
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
    "Sourcegraph" = {
      urls = [{
        template = "https://sourcegraph.com/search";
        params = [
          { name = "patternType"; value = "standard"; }
          { name = "groupBy"; value = "repo"; }
          { name = "q"; value = "context%3Aglobal+{searchTerms}"; }
        ];
      }];
      definedAliases = [ "@source" "@sourcegraph" ];
    };
    "Piped (piped.mha.fi)" = {
      urls = [{ template = "https://piped.mha.fi/results?search_query={searchTerms}"; }];
      definedAliases = [ "@piped" ];
    };
    "Metal Archives - Bands" = {
      urls = [{
        template = "https://www.metal-archives.com/search";
        params = [
          { name = "type"; value = "band_name"; }
          { name = "searchString"; value = "{searchTerms}"; }
        ];
      }];
      definedAliases = [ "@metal" "@metalarchives" ];
    };
    "Bandcamp" = {
      urls = [{ template = "https://bandcamp.com/search?q={searchTerms}"; }];
      definedAliases = [ "@band" "@bandcamp" ];
    };
    "Google Maps" = {
      urls = [{ template = "https://www.google.com/maps?&q={searchTerms}"; }];
      definedAliases = [ "@maps" "@gmaps" "@googlemaps" ];
    };
    "Merriam-Webster" = {
      urls = [{ template = "https://www.merriam-webster.com/dictionary/{searchTerms}"; }];
      definedAliases = [ "@mw" "@merriamwebster" "@en" "@english" ];
    };
    "Priberam" = {
      urls = [{ template = "https://dicionario.priberam.org/{searchTerms}"; }];
      definedAliases = [ "@priberam" "@pt" "@portugues" ];
    };
    "RAE" = {
      urls = [{ template = "https://dle.rae.es/{searchTerms}"; }];
      definedAliases = [ "@rae" "@es" "@espanol" ];
    };
    "Bing".metaData.hidden = true;
    "Google".metaData.alias = "@g";
    "DuckDuckGo".metaData.alias = "@ddg";
  };
}
