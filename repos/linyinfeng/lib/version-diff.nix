{ lib }:

{ oldSources, newSources }:

let
  importAndCallWithNullBuilders = file:
    let
      source = import file;
      params = builtins.functionArgs source;
      args = builtins.mapAttrs (_: _: null) params;
    in
    source args;
  old = importAndCallWithNullBuilders oldSources;
  new = importAndCallWithNullBuilders newSources;
  oldNames = lib.attrNames old;
  newNames = lib.attrNames new;
  initedPkgs = lib.filter (name: ! old ? ${name}) newNames;
  updatedPkgs = lib.filter (name: new.${name}.version != old.${name}.version)
    (lib.intersectLists newNames oldNames);
  removedPkgs = lib.filter (name: ! new ? ${name}) oldNames;
  initChangelogs = map (name: "${name}: init at ${new.${name}.version}") initedPkgs;
  updateChangelogs = map (name: "${name}: ${old.${name}.version} -> ${new.${name}.version}") updatedPkgs;
  removeChangelogs = map (name: "${name}: remove") removedPkgs;
in
lib.concatStrings (map (l: l + "\n") (lib.concatLists [ initChangelogs updateChangelogs removeChangelogs ]))
