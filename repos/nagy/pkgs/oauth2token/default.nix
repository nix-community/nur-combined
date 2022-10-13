{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "oauth2token";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "VannTen";
    repo = "oauth2token";
    rev = "9f99aaeb82d9fb53174ff96e58e9a097cce76617";
    sha256 = "sha256-40wBZzgj+qpj6hABT1zEjdtOx5v6CZWr8cFIFa7DPVo=";
  };

  doCheck = false;

  propagatedBuildInputs = with python3Packages; [ pyxdg google-auth-oauthlib ];

  meta = with lib; {
    description = "Simple cli tools to create and use oauth2token";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    mainProgram = "oauth2get";
  };
}
