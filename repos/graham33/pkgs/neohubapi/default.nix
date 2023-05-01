{ lib
, buildPythonPackage
, fetchFromGitLab
, async-property
}:

buildPythonPackage rec {
  pname = "neohubapi";
  version = "0.9";

  src = fetchFromGitLab {
    owner = "neohubapi";
    repo = "neohubapi";
    rev = "v${version}";
    sha256 = "sha256-+kMxB8liJ53rY0v3P72kY2aYI1/c7kYF3omEl6SKtlg=";
  };

  propagatedBuildInputs = [
    async-property
  ];

  checkInputs = [
  ];

  pythonImportsCheck = [ "neohubapi" ];

  meta = with lib; {
    homepage = "https://gitlab.com/neohubapi/neohubapi";
    description = "Async library to communicate with Heatmiser NeoHub 2 API";
    license = licenses.mit;
    maintainers = with maintainers; [ graham33 ];
  };
}
