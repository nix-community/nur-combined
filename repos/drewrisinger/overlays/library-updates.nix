self: super:
let
  overrideSuperVersionIfNewer = superPackage: localPackage:
    if super.lib.versionAtLeast superPackage.version localPackage.version then
      superPackage
    else
      localPackage;
in
rec {
  symengine = overrideSuperVersionIfNewer super.symengine (self.callPackage ../pkgs/libraries/symengine { });
}
