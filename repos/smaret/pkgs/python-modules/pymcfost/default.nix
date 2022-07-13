{ stdenv
, fetchgit
, buildPythonPackage
, astropy
, astroquery
, mcfost
, matplotlib
, numpy
, progressbar
, scipy
}:

buildPythonPackage rec {
  pname = "pymcfost";
  version = "0.1";

  src =
    fetchgit {
      url = "https://github.com/cpinte/pymcfost.git";
      rev = "6ffbe0b7f7fc1d874875c86aa65b89ebd129f33f";
      sha256 = "rYdO8S9bn3klVGrzTH+dy3kUceqQPZtTqEwUhMsh+LY=";
    };

  propagatedBuildInputs = [ astropy mcfost matplotlib numpy progressbar scipy ];

  doCheck = false;

}
