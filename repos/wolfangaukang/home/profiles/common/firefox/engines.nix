{
  general = {
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
    "sourcegraph" = {
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
    "piped.mha.fi" = {
      urls = [{ template = "https://piped.mha.fi/results?search_query={searchTerms}"; }];
      definedAliases = [ "@piped" ];
    };
    "Bing".metaData.hidden = true;
    "Google".metaData.alias = "@g";
    "DuckDuckGo".metaData.alias = "@ddg";
  };
  personal = {
    "Metal Archives - Bands" = {
      urls = [{
        template = "https://www.metal-archives.com/search";
        params = [
          { name = "type"; value = "band_name"; }
          { name = "searchString"; value = "{searchTerms}"; }
        ];
      }];
      definedAliases = [ "@metal" ];
    };
    "Bandcamp" = {
      urls = [{ template = "https://bandcamp.com/search?q={searchTerms}"; }];
      definedAliases = [ "@band" "@bandcamp" ];
    };
  };
}
