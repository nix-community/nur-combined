{ fetchFromGitHub, intel-compute-runtime }:
intel-compute-runtime.overrideDerivation (oldAttrs: rec {
  version = "24.39.31294.12";
  name = "${oldAttrs.pname}-${version}";
  src = fetchFromGitHub {
    owner = "intel";
    repo = "compute-runtime";
    tag = "${version}";
    hash = "sha256-7GNtAo20DgxAxYSPt6Nh92nuuaS9tzsQGH+sLnsvBKU=";
  };
})
