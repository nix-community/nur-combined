{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication {
  pname = "oauth2token";
  version = "0.0.3";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "VannTen";
    repo = "oauth2token";
    rev = "9f99aaeb82d9fb53174ff96e58e9a097cce76617";
    hash = "sha256-40wBZzgj+qpj6hABT1zEjdtOx5v6CZWr8cFIFa7DPVo=";
  };

  build-system = [ python3.pkgs.setuptools ];

  doCheck = false;

  propagatedBuildInputs = [
    python3.pkgs.pyxdg
    python3.pkgs.google-auth-oauthlib
  ];

  meta = {
    description = "Simple cli tools to create and use oauth2token";
    homepage = "https://github.com/VannTen/oauth2token";
    license = lib.licenses.gpl3;
    mainProgram = "oauth2get";
  };
}
