self: super:
let
  overrideSuperVersionIfNewer = superPackage: localPackage:
    if super.lib.versionAtLeast superPackage.version localPackage.version then
      superPackage
    else
      localPackage;
in
rec {

}
