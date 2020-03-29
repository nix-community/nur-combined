{ lib
, neovim
, utils ? import ./utils.nix {inherit lib;}
}:

let

  # Preprocesses args before passing in to `neovim.override`.
  #
  # Essentially, it translates our vim plugin schema to one accepted by `neovim.override`.
  # Currently all it does is remove `vimrc` from plugin lists, and combines them in `customRC`.
  wrapper = {
    ...
  } @args:

  let

    # Will sort packages via package name alphbetically.  This is default behavior of `lib.attrValues`.
    # - Structure of `packagesList`:
    # [
    #   # package one
    #   {
    #     start = [...];
    #     opt = [...];
    #   }
    #   # package two
    #   {
    #     ...
    #   }
    #   ...
    # ]
    packagesList = 
      lib.attrValues 
        # return empty set of path does not exist
        (lib.attrByPath ["configure" "packages"] {} args)  
    ;

    vimPlugPluginsList = lib.attrByPath ["configure" "plug" "plugins"] [] args;

    # Plugins composed from attr sets of:
    # 1. 'start' and 'opt' for each `packages.<package_name>`
    # 2. `vimPlugins`
    #
    # Structure of `pluginsList`:
    # [
    #   <plugin 1>
    #   {
    #     plugin = <plugin 2>;
    #     vimrc = ...;
    #   }
    #   ...
    # ]
    pluginsList = 
      lib.flatten
        (map 
          ( pkg: (pkg.start or []) ++ (pkg.opt or []) )
          packagesList)
      ++
      vimPlugPluginsList
    ;

    # Grab all the vimrc from each item in plugins list
    #
    # For vim packages, vimrc will be ordered alphabetically via package name in the override config.
    # i.e.; vimrc from plugins in `packages.a` will come before `packages.b`.
    customRC = 
      utils.combineVimRC 
        pluginsList 
        (lib.attrByPath ["configure" "customRC"] "" args)
    ;

    # Implementation assumes:
    # - "start" and "opt" attributes are not of type Attribute Set (currently are Lists).
    # - If an item in "start" and "opt" lists is an Attribute Set, assume it has "plugin" attribute
    #    with the corresponding plugin derivation as value.  Else, assume the item itself is the plugin derivation.
    packages = lib.mapAttrsRecursive
      (path: value: 
        (map 
          (p: if  (lib.isAttrs p) && !(lib.isDerivation p) 
      	then p.plugin
      	else p)
          value))
      # Note: we need a default package name, else neovim derivation won't build correctly.
      (lib.attrByPath ["configure" "packages"] { default = {}; } args)
    ;

    plugPlugins = 
      map 
        (p: if  (lib.isAttrs p) && !(lib.isDerivation p) 
            then p.plugin
            else p)
        vimPlugPluginsList
    ;

    # Create a duplicate args tree structure with our new values.
    newArgs = {
      configure = {
        inherit customRC packages;
        plug.plugins = plugPlugins;
      };
    };

    # Recursively merge new args with existing args
    overrides = lib.recursiveUpdate args newArgs; 

  in
    neovim.override overrides;

in
  lib.makeOverridable wrapper {}

