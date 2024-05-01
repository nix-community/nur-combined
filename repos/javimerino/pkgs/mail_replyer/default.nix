{ lib
, fetchFromGitHub
, python3Packages
, python-ollama
}:

python3Packages.buildPythonApplication {
  name = "mail_replyer";
  version = "0.1.0-20240501-779f84e635ed";
  pyproject = true;
  src = fetchFromGitHub {
    owner = "JaviMerino";
    repo = "mail_replyer";
    rev = "779f84e635ed9d5c509ba344be1b5639f316d374";
    hash = "sha256-iXaIXrDfYeR0w1R3VdPN8eOS6PFUVw9yTtOjm3GX09s=";
  };
  buildInputs = [
    python3Packages.hatchling
  ];
  propagatedBuildInputs = with python3Packages; [
    fire
    jinja2
    python-ollama
  ];

  meta = with lib; {
    description = "TODO";
    homepage = "https://github.com/JaviMerino/mail_replyer";
    maintainers = with maintainers; [ javimerino ];
    # license = licenses.something;
  };
}
