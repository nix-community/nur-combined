{
  default = "ddg";
  enginesSet = {
    # TODO: Separate this into categories
    # Search engines
    "bing".metaData.hidden = true;
    "google".metaData.hidden = true;
    "ddg".metaData.alias = "@ddg";
    "Searx (searx.work)" =
      let
        url = "https://searx.work";
      in
      {
        icon = "${url}/static/themes/simple/img/favicon.png";
        urls = [
          {
            template = "${url}/search";
            params = [
              {
                name = "q";
                value = "{searchTerms}";
              }
              {
                name = "safesearch";
                value = "0";
              }
              {
                name = "categories";
                value = "general";
              }
            ];
          }
        ];
        definedAliases = [ "@searx" ];
      };
    "Google - Web View" =
      let
        url = "https://google.com";
      in
      {
        icon = "${url}/favicon.ico";
        urls = [
          {
            template = "${url}/search";
            params = [
              {
                name = "udm";
                value = "14";
              }
              {
                name = "q";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        definedAliases = [ "@g" ];
      };
    # Nix/NixOS
    "nixpkgs - Packages" = {
      icon = "https://nixos.org/favicon.png";
      urls = [
        {
          template = "https://search.nixos.org/packages";
          params = [
            # TODO: Consider channels
            {
              name = "type";
              value = "packages";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [ "@nixpkgs" ];
    };
    "nixpkgs - Options" = {
      icon = "https://nixos.org/favicon.png";
      urls = [
        {
          template = "https://search.nixos.org/options";
          params = [
            # TODO: Consider channels
            {
              name = "type";
              value = "packages";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [ "@nixopts" ];
    };
    "nixpkgs - Revisions" = {
      icon = "https://nixos.org/favicon.png";
      urls = [
        {
          template = "https://lazamar.co.uk/nix-versions";
          params = [
            # TODO: Consider channels
            {
              name = "channel";
              value = "nixpkgs-unstable";
            }
            {
              name = "package";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [ "@nixrev" ];
    };
    "nixpkgs - PR Tracker" = {
      icon = "https://nixos.org/favicon.png";
      urls = [ { template = "https:///nixpk.gs/pr-tracker.html?pr={searchTerms}"; } ];
      definedAliases = [ "@nixpr" ];
    };
    # Code related
    "Sourcegraph" =
      let
        url = "https://sourcegraph.com";
      in
      {
        icon = "${url}/.assets/img/sourcegraph-mark.svg?v2";
        urls = [
          {
            template = "${url}/search";
            params = [
              {
                name = "patternType";
                value = "standard";
              }
              {
                name = "groupBy";
                value = "repo";
              }
              {
                name = "q";
                value = "context%3Aglobal+{searchTerms}";
              }
            ];
          }
        ];
        definedAliases = [
          "@source"
          "@sourcegraph"
        ];
      };
    "GitHub" =
      let
        url = "https://github.com";
      in
      {
        icon = "${url}/favicon.ico";
        urls = [ { template = "${url}/search?q={searchTerms}"; } ];
        definedAliases = [
          "@gh"
          "@github"
        ];
      };
    # Music/Videos
    "Bandcamp" = {
      icon = "https://s4.bcbits.com/img/favicon/favicon-32x32.png";
      urls = [ { template = "https://bandcamp.com/search?q={searchTerms}"; } ];
      definedAliases = [
        "@band"
        "@bandcamp"
      ];
    };
    "Piped (piped.mha.fi)" =
      let
        url = "https://piped.mha.fi";
      in
      {
        icon = "${url}/favicon.ico";
        urls = [ { template = "${url}/results?search_query={searchTerms}"; } ];
        definedAliases = [ "@piped" ];
      };
    # Maps
    "Google Maps" =
      let
        url = "https://maps.google.com";
      in
      {
        icon = "${url}/favicon.ico";
        urls = [ { template = "${url}/?&q={searchTerms}"; } ];
        definedAliases = [
          "@maps"
          "@gmaps"
          "@googlemaps"
        ];
      };
    # Dictionaries
    "Merriam-Webster" =
      let
        url = "https://www.merriam-webster.com";
      in
      {
        icon = "${url}/favicon.ico";
        urls = [ { template = "${url}/dictionary/{searchTerms}"; } ];
        definedAliases = [
          "@mw"
          "@merriamwebster"
          "@en"
          "@english"
        ];
      };
    "priberam" =
      let
        url = "https://dicionario.priberam.org";
      in
      {
        icon = "${url}/favicon.ico";
        urls = [ { template = "${url}/{searchTerms}"; } ];
        definedAliases = [
          "@priberam"
          "@pt"
          "@portugues"
        ];
      };
    "RAE" =
      let
        url = "https://dle.rae.es";
      in
      {
        icon = "${url}/favicon.ico";
        urls = [ { template = "${url}/{searchTerms}"; } ];
        definedAliases = [
          "@rae"
          "@es"
          "@espanol"
        ];
      };
    # Package Managers
    "Crates (Rust)" =
      let
        url = "https://crates.io";
      in
      {
        icon = "${url}/favicon.ico";
        urls = [ { template = "${url}/search?q={searchTerms}"; } ];
        definedAliases = [ "@crates" ];
      };
    "PyPI (Python)" =
      let
        url = "https://pypi.org";
      in
      {
        icon = "${url}/static/images/favicon.35549fe8.ico";
        urls = [ { template = "${url}/search/?q={searchTerms}"; } ];
        definedAliases = [ "@pypi" ];
      };
    # Docs
    "pkgs.go.dev (Go)" =
      let
        url = "https://pkg.go.dev";
      in
      {
        icon = "${url}/static/shared/icon/favicon.ico";
        urls = [ { template = "${url}/search?q={searchTerms}"; } ];
        definedAliases = [ "@godev" ];
      };
    "docs.rs (Rust)" =
      let
        url = "https://docs.rs";
      in
      {
        icon = "${url}/-/static/favicon.ico";
        urls = [ { template = "${url}/releases/search?query={searchTerms}"; } ];
        definedAliases = [ "@docsrs" ];
      };
    # Other
    "Shellcheck (Shell)" =
      let
        url = "https://www.shellcheck.net/wiki";
      in
      {
        icon = "https://t0.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=http://www.shellcheck.net&size=32";
        urls = [ { template = "${url}/{searchTerms}"; } ];
        definedAliases = [ "@shellcheck" ];
      };
    "Metal Archives - Bands" =
      let
        url = "https://www.metal-archives.com";
      in
      {
        icon = "${url}/favicon.ico";
        urls = [
          {
            template = "${url}/search?";
            params = [
              {
                name = "type";
                value = "band_name";
              }
              {
                name = "searchString";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        definedAliases = [
          "@metal"
          "@metalarchives"
        ];
      };
    "home-manager - Options" = {
      icon = "https://home-manager.dev/favicon.ico";
      urls = [
        {
          template = "https://home-manager-options.extranix.com/";
          params = [
            {
              name = "release";
              value = "master";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [ "@hm" ];
    };
    "amazondotcom-us".metaData.hidden = true;
  };
}
