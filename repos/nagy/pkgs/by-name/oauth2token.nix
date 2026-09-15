{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "oauth2token";
  version = "0.0.3";
  format = "setuptools";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-3wJHPYP74rTdqAfVKZ7LrzwP4tCeV+VRasoqs1uw/vg=";
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
    maintainers = with lib.maintainers; [ nagy ];
  };
})
