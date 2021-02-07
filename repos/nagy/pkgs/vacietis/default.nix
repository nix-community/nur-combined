{ lispPackages, fetchFromGitHub }:

lispPackages.buildLispPackage rec {
  baseName = "vacietis";
  version = "2012-11-29";

  buildSystems = [ "vacietis" ];

  description = "C to Common Lisp compiler";
  deps = with lispPackages; [
    named-readtables
    anaphora
    babel
    cl-ppcre
    cl-fad
  ];
  src = fetchFromGitHub {
    owner = "vsedach";
    repo = "Vacietis";
    rev = "50c1b82a9f906c270cd8cbc7a1fe7f7281ebad2f";
    sha256 = "0xynh698vr719wmxcj70wsxw8xlfq7b2br6v28vwkm06p1lxawra";
  };

  packageName = "vacietis";

  asdFilesToKeep = [ "vacietis.asd" ];
}
