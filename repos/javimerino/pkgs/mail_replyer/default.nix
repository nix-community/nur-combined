{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonApplication {
  name = "mail_replyer";
  version = "0.1.0-20240527-08492c18d905";
  pyproject = true;
  src = fetchFromGitHub {
    owner = "JaviMerino";
    repo = "mail_replyer";
    rev = "08492c18d905f885be663a07c75ee3d3ef256114";
    hash = "sha256-F8dm1ddh1CsExcYLRUO55z4rQqVRBO2lzYhiyUH78zc=";
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
