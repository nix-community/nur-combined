self: super:
let
  newPackagePaths = import /${super.vacuRoot}/androidPackages { inherit (super) lib vaculib; };
in
builtins.mapAttrs (_: path: self.callPackage path { }) newPackagePaths
