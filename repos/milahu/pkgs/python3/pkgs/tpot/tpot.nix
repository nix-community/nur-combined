{ lib
, buildPythonPackage
, python
, fetchFromGitHub
, deap
, nose
, numpy
, scikit-learn
, imbalanced-learn
, scipy
, tqdm
, update-checker
, stopit
, pandas
, joblib
, xgboost
, torch
}:

buildPythonPackage rec {
  pname = "tpot";
  version = "0.12.0";
  src = fetchFromGitHub {
    owner = "EpistasisLab";
    repo = "tpot";
    rev = "v${version}";
    sha256 = "sha256-zuCPUijrUzi73RTaEeGPoYssaAVkCjWF5z+ZPFVDSqY=";
  };
  propagatedBuildInputs = [
    deap
    nose
    numpy
    scikit-learn
    imbalanced-learn
    scipy
    tqdm
    update-checker
    stopit
    pandas
    joblib
    xgboost
  ];
  checkInputs = [
    torch
  ];
  meta = with lib; {
    homepage = "https://github.com/EpistasisLab/tpot";
    description = "A Python tool that automatically creates and optimizes machine learning pipelines using genetic programming";
    license = licenses.lgpl3;
  };
}
