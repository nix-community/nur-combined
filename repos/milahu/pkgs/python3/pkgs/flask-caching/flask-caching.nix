{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "flask-caching";
  version = "2.0.2";
  #version = "2.0.2.2023.04.28";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "pallets-eco";
    repo = "flask-caching";
    rev = "v${version}";
    hash = "sha256-arGsLteTOaMQnryj6xsoIwql4HDutpL36cLsuG3Z3tc=";
    # fix? ERROR: Could not find a version that satisfies the requirement Flask<3
    # no
    #rev = "7b1b2ce5ea940c870f45e6ca57232db028bfd475";
    #hash = "sha256-TuG+61q2qMPhTAGJFdFlAPkJBDxZuUgCx/u6BkZSU7U=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    flask
    cachelib
  ];

  # fix: ERROR: Could not find a version that satisfies the requirement Flask<3
  postPatch = ''
    sed -i 's/"Flask < 3"/"Flask"/' setup.py
    sed -i 's/"cachelib >= 0.9.0, < 0.10.0"/"cachelib"/' setup.py
  '';

  pythonImportsCheck = [ "flask_caching" ];

  meta = with lib; {
    description = "A caching extension for Flask";
    homepage = "https://github.com/pallets-eco/flask-caching";
    changelog = "https://github.com/pallets-eco/flask-caching/blob/${src.rev}/CHANGES.rst";
    license = with licenses; [ ];
    maintainers = with maintainers; [ ];
  };
}
