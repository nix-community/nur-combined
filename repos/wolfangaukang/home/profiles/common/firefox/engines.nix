{
  default = "MetaGer";
  enginesSet = {
    # TODO: Separate this into categories
    # Search engines
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
    "Bing".metaData.hidden = true;
    "Google".metaData.alias = "@g";
    "DuckDuckGo".metaData.alias = "@ddg";
    # Nix/NixOS
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
    "nixpkgs - Revisions" = {
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
      urls = [{ template = "https:///nixpk.gs/pr-tracker.html?pr={searchTerms}"; }];
      definedAliases = [ "@nixpr" ];
    };
    # Code related
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
    "GitHub" = {
      urls = [{ template = "https://github.com/search?q={searchTerms}"; }];
      definedAliases = [ "@gh" "@github" ];
    };
    # Music/Videos
    "Bandcamp" = {
      urls = [{ template = "https://bandcamp.com/search?q={searchTerms}"; }];
      definedAliases = [ "@band" "@bandcamp" ];
    };
    "Piped (piped.mha.fi)" = {
      urls = [{ template = "https://piped.mha.fi/results?search_query={searchTerms}"; }];
      definedAliases = [ "@piped" ];
    };
    # Maps
    "Google Maps" = {
      urls = [{ template = "https://www.google.com/maps?&q={searchTerms}"; }];
      definedAliases = [ "@maps" "@gmaps" "@googlemaps" ];
    };
    # Dictionaries
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
    # Other
    "metal archives - bands" = {
      urls = [{
        template = "https://www.metal-archives.com/search";
        params = [
          { name = "type"; value = "band_name"; }
          { name = "searchstring"; value = "{searchterms}"; }
        ];
      }];
      definedaliases = [ "@metal" "@metalarchives" ];
    };
  };
}
