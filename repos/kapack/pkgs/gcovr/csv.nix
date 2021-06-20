{ lib
, python3Packages
, fetchgit
}:

python3Packages.buildPythonPackage rec {
  pname = "gcovr";
  version = "4.2-with-csv";

  src = fetchgit {
    url = "https://github.com/gcovr/gcovr.git";
    rev = "a67fa65e00795febaf141098a19fc99cb8d2294e";
    sha256 = "17qp30w11ssgh3fh325amgi6ywlf63cpdjmgysa52dwlfwwn7bgl";
  };

  propagatedBuildInputs = [
    python3Packages.jinja2
    python3Packages.lxml
    python3Packages.pygments
  ];

  # There are no unit tests in the pypi tarball. Most of the unit tests on the
  # github repository currently only work with gcc5, so we just disable them.
  # See also: https://github.com/gcovr/gcovr/issues/206
  doCheck = false;

  pythonImportsCheck = [
    "gcovr"
    "gcovr.workers"
    "gcovr.configuration"
  ];

  meta = with lib; {
    description = "A Python script for summarizing gcov data";
    license = licenses.bsd0;
    homepage = "https://www.gcovr.com/";
  };

}
