{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage {
  pname = "bson";
  version = "0.5.10";

  src = fetchFromGitHub {
    owner = "py-bson";
    repo = "bson";
    rev = "a68073661c637051985f3d0c24b8c7828a4c3ff4";
    sha256 = "0gh0kbblmxnidr9xp05d8nlfjna7461bxx82l82mwwz1a7i7x36d";
  };

  propagatedBuildInputs = with python3Packages; [ python-dateutil six ];

  meta = with lib; {
    description = "Independent BSON codec for Python that doesn't depend on MongoDB";
    homepage = "https://github.com/py-bson/bson";
    license = with licenses; [ bsd3 asl20 ];
    maintainers = [ maintainers.sikmir ];
  };
}
