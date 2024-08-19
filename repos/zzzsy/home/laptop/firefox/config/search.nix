{
  force = true;
  default = "Google UK";
  engines = {
    #@TODO
    "Google".metaData.hidden = true;
    "Wikipedia (en)".metaData.alias = "@w";
    "Google UK" = {
      urls = [
        {
          template = "https://www.google.co.uk/search";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [ "@g" ];
    };
    "GitHub" = {
      urls = [
        {
          template = "https://github.com/search";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [ "@gh" ];
    };
    "Nix" = {
      urls = [
        {
          template = "https://search.nixos.org/packages";
          params = [
            {
              name = "channel";
              value = "unstable";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      # icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@np" ];
    };
    "Nixpkgs Issues" = {
      urls = [
        {
          template = "https://github.com/NixOS/nixpkgs/issues";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [ "@ni" ];
    };
  };
}
