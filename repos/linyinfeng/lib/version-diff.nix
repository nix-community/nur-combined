{ lib }:

{ oldSources, newSources }:

let
  params = { fetchgit = null; fetchurl = null; fetchFromGitHub = null; };
  old = import oldSources params;
  new = import newSources params;
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
lib.concatStringsSep "\n" (lib.concatLists [ initChangelogs updateChangelogs removeChangelogs ])
