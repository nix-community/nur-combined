self: super:
let
  newPackagePaths = import /${super.vacuRoot}/packages { inherit (super) lib vaculib; };
in
builtins.mapAttrs (_: path: self.callPackage path { }) newPackagePaths
