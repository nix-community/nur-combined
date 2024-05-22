{ nix
, yarn
, buildNodeModule
, loadNixExpression
, parseModuleID
, selectModules
}:

with builtins;

let
  tree = loadNixExpression ./yarn.lock.nix { };
  pkgInfo = fromJSON (readFile ./package.json);
  inherit (pkgInfo) name version files;
  id = parseModuleID name;
  src = let p = ./.;
  in path {
    name = "${id.scope}-${id.name}";
    path = p;
    filter = _path: _:
      let
        rp = toString
          (replaceStrings [ ((toString p) + "/") ] [ "" ] (toString _path));
      in elem rp files;
  };
  
in buildNodeModule {
  inherit id version src;
  lifeCycleScripts = [ ];
  # Replace links to `yarn` and `nix` with paths to nix store.
  inherit yarn nix;
  prePatch = ''
    substituteAllInPlace lib/proxy.js
  '';
  modules = selectModules ./package.json {
    inherit tree;
    sections = [ "dependencies" ];
  };
}
