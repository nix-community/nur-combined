{ lib, fetchPypi, buildPythonPackage
, numpy
, absl-py
, mock
}:

buildPythonPackage rec {
  pname = "tensorflow-estimator";

  /*
  version = "2.8.0";
  format = "wheel";
  src = fetchPypi {
    pname = "tensorflow_estimator";
    inherit version format;
    sha256 = "vujgUgxgrn6vbKjLRsWp9LRXJVMTgNuPvjj8tIR4trs=";
  };
  */
  # tensorflow requires tf-estimator-nightly==2.8.0.dev2021122109
  # https://pypi.org/project/tf-estimator-nightly/#files
  version = "2.8.0.dev2021122109";
  format = "wheel";
  src = fetchPypi {
    pname = "tf_estimator_nightly";
    inherit version format;
    sha256 = "AGWgTjlrKJC9GXYfwd51Wc6v66EoOfjbLH50c6+q9hI=";
  };

  propagatedBuildInputs = [ mock numpy absl-py ];

  meta = with lib; {
    description = "TensorFlow Estimator is a high-level API that encapsulates model training, evaluation, prediction, and exporting.";
    homepage = "http://tensorflow.org";
    license = licenses.asl20;
    maintainers = with maintainers; [ jyp ];
  };
}

