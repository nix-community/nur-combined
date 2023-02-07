{ self }:
let
  # This is required for any system needing to reference the flake itself from
  # within the config. It will be available as an argument to the 
  # config as "flake" if used as defined below
  flake = self;
in { config._module.args = { inherit flake; }; }
