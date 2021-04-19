{ lib
, buildPythonPackage
, fetchPypi
, isPy3k
, numba
, numpy
, scipy
  # Test Inputs
, pytestCheckHook
, dask
}:

buildPythonPackage rec {
  pname = "sparse";
  version = "0.9.1";

  disabled = !isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "04gfwm1y9knryx992biniqa3978n3chr38iy3y4i2b8wy52fzy3d";
  };

  propagatedBuildInputs = [
    numba
    numpy
    scipy
  ];
  checkInputs = [ pytestCheckHook dask ];
  dontUseSetuptoolsCheck = true;
  preCheck = "pushd $TMPDIR/$sourceRoot";
  postCheck = "popd";

  pythonImportsCheck = [ "sparse" ];

  meta = with lib; {
    description = "Sparse n-dimensional arrays computations";
    homepage = "https://sparse.pydata.org/en/stable/";
    changelog = "https://sparse.pydata.org/en/stable/changelog.html";
    license = licenses.bsd3;
    maintainers = [ maintainers.costrouc ];
  };
}
