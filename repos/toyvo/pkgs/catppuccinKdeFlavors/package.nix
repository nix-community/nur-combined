{ catppuccin-kde, lib, ... }:
let
  combinations = {
    "frappe-red" = {
      flavor = "frappe";
      accent = "red";
    };
    "latte-red" = {
      flavor = "latte";
      accent = "red";
    };
    "latte-pink" = {
      flavor = "latte";
      accent = "pink";
    };
  };
  packages = lib.mapAttrs' (name: value: {
    name = "catppuccin-kde-${name}";
    value = catppuccin-kde.override {
      flavour = [ value.flavor ];
      accents = [ value.accent ];
      winDecStyles = [ "classic" ];
    };
  }) combinations;
in
lib.recurseIntoAttrs (packages)
