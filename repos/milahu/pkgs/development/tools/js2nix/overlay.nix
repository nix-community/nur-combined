{ lib }:

# This file contains a set of function that are being applyed to a package
# if they are declared in the `overlay` section of `package.json` file.
# See <link to the docs> for more details.
#
# The `self` and `super` are references 
# to the resulting set of packages for a whole closure, coming from
# generated Nix expressions, like ./yarn.lock.nix.

let
  getLocalPath = package-json: value:
    # A naive check if the src is a path.
    assert (lib.hasPrefix "." value) || (lib.hasPrefix "/" value);

    builtins.path {
      # See: https://nixos.org/manual/nix/stable/#builtin-path
      name = builtins.replaceStrings [ "." "@" "+" ] [ "-" "-" "-" ] (builtins.baseNameOf value);
      path =
        if lib.hasPrefix "." value
        # relative to the given `package.json` file
        then (builtins.dirOf package-json) + "/${value}"
        # an absolute path, nothing to do.
        else value;
      filter = p: t: ! (t == "directory" && lib.hasSuffix "node_modules" p);
    };
in
{
  # This is the entry point function that iterates over all the declarations in
  # the `overlay` section in the `package.json` file and invoke functions declared
  # in this attr set.
  # 
  # Functions' naming convention:
  # The "overlays.babel-jest.addDependencies" declaration corresponds to the 
  # `fn.addDependencies` function declared below that is being invoked with 
  # an attr set of arguments:
  # - pkg
  # - value (the value from the `package.json#overlays.babel-jest.addDependencies`)
  # - self
  # - super
  # - package-json (the Nix's path type)
  # - parsed (parsed `package.json` content)
  #
  # Add a function with prefix `fn.` so it will be automatically invoked. The function 
  # must return overriden package derivation. Be careful with `override` and `overrideAttrs`
  # because the `override` called after `overrideAttrs` can cause issues.
  #
  __functor = this: package-json: self: super:
    let
      parsed = lib.importJSON package-json;
      _ovrl = lib.attrByPath [ "js2nix" "overlay" ] { } parsed;
      localPkgsOverlay =
        let
          # Get and merge the dependencies sections as an attrset
          deps = builtins.foldl' (acc: curr: if lib.hasAttr curr parsed then acc // parsed.${curr} else acc) { } [
            "dependencies"
            "devDependencies"
          ];
          # Filter out to have only the local ones, by prefix of "." or "/".
          localDeps = builtins.filter
            (e: let p = builtins.elemAt e 1; in (lib.hasPrefix "." p) || (lib.hasPrefix "/" p))
            (lib.mapAttrsToList (name: value: [ name value ]) deps);
        in
        builtins.foldl'
          (acc: curr:
            let
              name = builtins.elemAt curr 0;
              value = builtins.elemAt curr 1;

              pkg = super.${super.__meta__.aliases.${name}};
            in
            acc // {
              ${super.__meta__.aliases.${name}} = this.fn.src {
                inherit pkg value self super package-json parsed;
              };
            }
          )
          { }
          localDeps;
      overlay = builtins.foldl'
        (acc: curr:
          let
            target = acc.${super.__meta__.aliases.${curr}} or super.${super.__meta__.aliases.${curr}};
            declaration = _ovrl.${curr};
          in
          acc // {
            ${super.__meta__.aliases.${curr}} = builtins.foldl'
              (prev: fn: this.fn.${fn} {
                pkg = prev;
                value = declaration.${fn};
                inherit self super package-json parsed;
              })
              target
              (builtins.attrNames declaration);
          })
        localPkgsOverlay
        (builtins.attrNames _ovrl);
    in
    overlay;

  # Add modules.
  #
  fn.addDependencies = { pkg, value, self, super, ... }:
    assert builtins.typeOf value == "list";
    let
      modules = builtins.map
        (name:
          assert builtins.typeOf name == "string";
          self.${super.__meta__.aliases.${name}})
        value;
    in
    pkg.override (x: {
      modules = (x.modules or [ ]) ++ modules;
    });

  fn.doCheck = { pkg, value, ... }: 
    # Accept only boolean as an input.
    assert builtins.typeOf value == "bool"; 
    pkg.override { doCheck = value; };

  # Override the src field.
  #
  fn.src = { pkg, value, package-json, ... }:
    # Accept only string or set as an input.
    assert builtins.typeOf value == "string" || builtins.typeOf value == "set";
    pkg.override (x: {
      src =
        if builtins.typeOf value == "string"
        then getLocalPath package-json value
        else x.src.override value;
    });

  fn.patches = { pkg, value, package-json, ... }:
    # Accept only list of string as an input.
    assert builtins.typeOf value == "list";
    pkg.override (x: {
      patches = builtins.map (getLocalPath package-json) value;
    });

  fn.lifeCycleScripts = { pkg, value, ... }:
    # Accept only list of string as an input.
    assert builtins.typeOf value == "list";
    pkg.override (x: {
      lifeCycleScripts = value;
    });
}
