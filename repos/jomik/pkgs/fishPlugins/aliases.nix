# Deprecated aliases - for backward compatibility

lib: overriden:

with overriden;

let
  # Removing recurseForDerivation prevents derivations of aliased attribute
  # set to appear while listing all the packages available.
  removeRecurseForDerivations = alias: with lib;
    if alias.recurseForDerivations or false then
      removeAttrs alias ["recurseForDerivations"]
    else alias;

  # Disabling distribution prevents top-level aliases for non-recursed package
  # sets from building on Hydra.
  removeDistribute = alias: with lib;
    if isDerivation alias then
      dontDistribute alias
    else alias;

  # Make sure that we are not shadowing something from
  # all-packages.nix.
  checkInPkgs = n: alias: if builtins.hasAttr n overriden
                          then throw "Alias ${n} is still in fish-plugins"
                          else alias;

  mapAliases = aliases:
     lib.mapAttrs (n: alias: removeDistribute
                             (removeRecurseForDerivations
                              (checkInPkgs n alias)))
                     aliases;
in mapAliases {
  theme-eden = fish-theme-eden;
  theme-spacefish = spacefish;
  theme-pure = pure;
  fasd = fish-fasd;
}
