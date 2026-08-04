{
  lib,
  python3Packages,

  khoca,
  regina-normal,
  ...
}:

lib.makeScope python3Packages.newScope (python-self: {

  khoca = python-self.callPackage ./khoca {
    inherit khoca;
  };

  regina = python-self.callPackage ./regina {
    inherit regina-normal;
  };

  stabiliser-tools = python-self.callPackage ./stabiliser-tools { };

})
