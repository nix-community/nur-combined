{ lib
, python3
, fetchFromGitHub
, fetchpatch
}:

python3.pkgs.buildPythonPackage rec {
  pname = "varname";
  version = "0.13.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pwwang";
    repo = "python-varname";
    rev = version;
    hash = "sha256-Zwqc8V4yR8lpK3o+vBkK01gL9u2srfXx8bV5c3xv8ZI=";
  };

  # switch to poetry-core
  # https://github.com/pwwang/python-varname/pull/113
  patches = [
    (fetchpatch {
      url = "https://github.com/pwwang/python-varname/pull/113/commits/cd4cf31d087212202e84e94df8ec57d005cc8c89.patch";
      hash = "sha256-oD0POa2kO2VHqXx9jU5S9Iu1CRNVmqKRPC3WjqI+f5I=";
    })
  ];

  nativeBuildInputs = [
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    executing
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    all = [
      asttokens
      pure_eval
    ];
  };

  pythonImportsCheck = [ "varname" ];

  meta = with lib; {
    description = "Dark magics about variable names in python";
    homepage = "https://github.com/pwwang/python-varname";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
