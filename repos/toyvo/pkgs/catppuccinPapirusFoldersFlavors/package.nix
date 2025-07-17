{ catppuccin-papirus-folders, lib, ... }:
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
    name = "catppuccin-papirus-folders-${name}";
    value = catppuccin-papirus-folders.override {
      inherit (value) flavor accent;
    };
  }) combinations;
in
lib.recurseIntoAttrs (packages)
