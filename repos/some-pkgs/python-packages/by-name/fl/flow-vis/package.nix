{ lib
, buildPythonPackage
, fetchFromGitHub
, numpy
}:

buildPythonPackage rec {
  pname = "optical-flow-visualization";
  version = "0.1";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "tomrunia";
    repo = "OpticalFlow_Visualization";
    rev = "v${version}";
    hash = "sha256-Wkc4E+Q2M26h7z/lJSe1ZaqvbAKpcxv/AiAc2C6rHsA=";
  };

  propagatedBuildInputs = [
    numpy
  ];

  pythonImportsCheck = [ "flow_vis" ];

  meta = with lib; {
    description = "Python optical flow visualization following Baker et al. (ICCV 2007) as used by the MPI-Sintel challenge";
    homepage = "https://github.com/tomrunia/OpticalFlow_Visualization";
    license = licenses.mit;
    maintainers = with maintainers; [ SomeoneSerge ];
  };
}
