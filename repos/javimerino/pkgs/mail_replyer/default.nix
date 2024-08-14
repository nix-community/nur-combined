{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonApplication {
  name = "mail_replyer";
  version = "0.1.0-20240813-67b189e9dc0d";
  pyproject = true;
  src = fetchFromGitHub {
    owner = "JaviMerino";
    repo = "mail_replyer";
    rev = "67b189e9dc0d7881967501973320d40e90bd1b48";
    hash = "sha256-XUCkgsq16SjxVFNqzvsfG9JqF+N0tQCWk4G7aGvKEPU=";
  };
  buildInputs = [
    python3Packages.hatchling
  ];
  propagatedBuildInputs = with python3Packages; [
    fire
    jinja2
    ollama
  ];

  meta = with lib; {
    description = "Test LLMs to write emails";
    homepage = "https://github.com/JaviMerino/mail_replyer";
    maintainers = with maintainers; [ javimerino ];
    license = licenses.mit;
  };
}
