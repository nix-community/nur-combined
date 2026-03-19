{
  lib,
  python3,
  fetchFromGitHub,
  shellcheck,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "yaml-shellcheck";
  version = "1.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mschuett";
    repo = "yaml-shellcheck";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I+HkpUV1OCXau+i/ni0WX2bzTPFI705hrmVL9W9Co+8=";
  };

  postPatch = ''
    substituteInPlace yaml_shellcheck.py \
      --replace-fail 'default="shellcheck"' 'default="${lib.getBin shellcheck}/bin/shellcheck"'
  '';

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    ruamel-yaml
  ];

  pythonRelaxDeps = [
    "ruamel.yaml"
  ];

  pythonImportsCheck = [
    "yaml_shellcheck"
  ];

  meta = {
    description = "Wrapper script to run shellcheck on YAML CI-config files";
    homepage = "https://github.com/mschuett/yaml-shellcheck";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "yaml-shellcheck";
  };
})
