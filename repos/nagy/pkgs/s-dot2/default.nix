{ lispPackages, fetchgit, ... }:

lispPackages.buildLispPackage {

  baseName = "s-dot2";
  version = "1.3.0";

  buildSystems = [ ];

  description = "s-dot2";

  deps = [ ];

  src = fetchgit {
    url = "https://notabug.org/cage/s-dot2";
    rev = "dccd647127183d2e5885de29fc0c38918a79a612";
    sha256 = "0q8293fhdb1i2mgmck5611z92p71g9fcarrm87nsr6s21w29hzrz";
  };
}
