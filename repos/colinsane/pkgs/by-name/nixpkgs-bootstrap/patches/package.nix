# track PRs on their way to master: <https://nixpk.gs/pr-tracker.htm>
{
  vendorPatch,
}:
let
  maybePatchNames = map
    (name: builtins.match "(.*)\\.patch" name)
    (builtins.attrNames (builtins.readDir ./.))
  ;
  nestedPatchNames = builtins.filter (v: v != null) maybePatchNames;
  patchNames = map (matches: builtins.head matches) nestedPatchNames;
in
  builtins.listToAttrs (
    map
      (name: {
        inherit name;
        value = vendorPatch { inherit name; };
      })
      patchNames
  )
  //
  {
    recurseForDerivations = true;
  }
