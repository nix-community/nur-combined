{ self }:
with builtins;
let
  inherit (self.inputs.stable.lib.attrsets) filterAttrs attrValues;
  path = ./. + "/../home-manager-modules";

  # Filter files within the home-manager-modules root folder for
  # only directories. Where they exist, assume the standard 
  # default.nix exists for loading.
  module-folders =
    filterAttrs (name: value: value == "directory") (readDir path);

  # With a list of directories, create a map of those being imported without
  # arguments to be loaded later.
  module-configs = attrValues (mapAttrs (name: _: {
    # WARNING! It's extremely unlikely that the argument-set expected of home-manager
    # will change, but if a new argument is added, this WILL ERROR (will only ever)
    # occur on an update of home-manager release: this _could_ be solved by
    # changing each of these to a variadic function however we intentionally 
    # so that if new arguments are added we are aware of them rahter than missing
    # potentially important additions to the module.
    # So; if you are getting an error future person and the trace points to just
    # below this comment, it'll likely be an addition or removal of a argument passed
    # by home manager.
    "${name}" = { config, pkgs, lib, options, specialArgs, modulesPath
      , nixosConfig ? { }, osConfig, darwinConfig ? { } }:
      import "${path}/${name}/default.nix" {
        inherit config pkgs lib options specialArgs modulesPath nixosConfig
          osConfig darwinConfig;
      };
  }) module-folders);

  # Fold set values by the module name as the key and set as
  # the value, enabling us to expose this as a top-level 
  # flake construct to be presented once, but available
  # across anything that has access to self/flake. (including external)
  # This means we can load modules arbitrarily from various locations.
  # This obviously might be bad if we're not clear on them being explicitly
  # home-manager modules!
  #
  # An example of the above in practice: 
  # let cool-modules = with self.common.home-manager-modules [ firefox rofi ]; in ...
  #
  # Alternatively via inherit:
  # inherit (self.common.home-manager-modules) firefox rofi;
  # let cool-users = [ jay ]; in ...
  # 
  # To see this more interactively use the repl:
  # $ nix repl
  # nix-repl> :lf .
  # nix-repl> common.home-manager-modules.alacritty
  # «lambda @ /nix/store/g90cys2l7mc35ph6b8b0yc2crp2v7mr9-home-manager-modules/alacritty/default.nix:1:1»
  home-manager-modules =
    builtins.foldl' (acc: module: acc // module) { } module-configs;

in home-manager-modules
