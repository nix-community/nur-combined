{ lib
, buildPythonPackage
, fetchFromGitHub
, mpmath
, numpy
, scipy
  # test inputs
, pytestCheckHook
, nose
}:

buildPythonPackage rec {
  pname = "algopy";
  version = "0.5.7";

  src = fetchFromGitHub {
    owner = "b45ch1";
    repo = pname;
    rev = "1e2430f803289bbaed6bbdff6c28f98d7767835c"; # untagged, commit lists it as 0.5.7
    sha256 = "1b0mm0y9rqcjzx6jbkg9zz1x0m3wba25jq28ncwnn9myq0algyk8";
  };

  propagatedBuildInputs = [
    mpmath
    numpy
    scipy
  ];

  postPatch = ''
    pushd ./algopy

    substituteInPlace ./tests/test_nthderiv.py \
      --replace "numpy.testing.decorators" "pytest.mark" \
      --replace "import numpy.testing" "import numpy.testing; import pytest"
    substituteInPlace ./utpm/tests/test_utpm_convenience.py \
      --replace "from numpy.testing.decorators import skipif" "import pytest" \
      --replace "@skipif" "@pytest.mark.skipif"
    substituteInPlace ./utpm/tests/test_utpm.py \
      --replace "from numpy.testing import *" "from numpy.testing import TestCase, assert_array_equal, assert_almost_equal, assert_array_almost_equal, assert_allclose, assert_array_less, assert_equal; import pytest" \
      --replace "@decorators.skipif" "@pytest.mark.skipif"
    substituteInPlace ./utpm/tests/test_special_function_identities.py \
      --replace "from numpy.testing.decorators import skipif" "import pytest" \
      --replace "@skipif" "@pytest.mark.skipif"
    substituteInPlace ./tracer/tests/test_tracer.py \
      --replace "from numpy.testing import *" "from numpy.testing import TestCase, assert_array_equal, assert_almost_equal, assert_array_almost_equal, assert_allclose, assert_array_less, assert_equal; import pytest" \
      --replace "@decorators.skipif" "@pytest.mark.skipif"
    substituteInPlace ./tests/test_linalg.py \
      --replace "from numpy.testing.decorators import skipif" "import pytest" \
      --replace "@skipif" "@pytest.mark.skipif"
    substituteInPlace ./tests/test_special.py \
      --replace "from numpy.testing import *" "from numpy.testing import TestCase, assert_array_equal, assert_almost_equal, assert_array_almost_equal, assert_allclose, assert_array_less, assert_equal; import pytest" \
      --replace "@decorators.skipif" "@pytest.mark.skipif"
    substituteInPlace ./tests/test_globalfuncs.py \
      --replace "from numpy.testing.decorators import *" "import pytest" \
      --replace "@skipif" "@pytest.mark.skipif"
    substituteInPlace ./tests/test_examples.py \
      --replace "from numpy.testing.decorators import *" "import pytest" \
      --replace "@skipif" "@pytest.mark.skipif"

    popd
  '';

  doCheck = false;  # tests are out of date, rely on numpy. Would require a near-total rewrite of the tests to fix.
  pythonImportsCheck = [ "algopy" ];
  dontUseSetuptoolsCheck = true;
  checkInputs = [ pytestCheckHook nose ];

  disabledTests = [
    # Removed from scipy
    "hyp2f0"
    "hyp1f2"
    # Fails
    "test_hyperu_rational"
  ];

  # pytestFlagsArray = [
  #   "--ignore=utpm/tests/test_utpm_convenience.py"
  #   "--ignore=utpm/tests/test_special_function_identities.py"
  #   "--ignore=tracer/tests/test_tracer.py"
  #   "--ignore=tests/test_nthderiv.py"
  #   "--ignore=tests/test_special.py"
  #   "--ignore=tests/test_linalg.py"
  #   "--ignore=tests/test_globalfuncs.py"
  #   "--ignore=tests/test_examples.py"
  # ];

  meta = with lib; {
    description = "Research Prototype for Algorithmic Differentation in Python";
    homepage = "https://pythonhosted.org/algopy/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
