{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "binapy";
  version = "0.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "guillp";
    repo = "binapy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WaRf2bj8MjbAfPRLwXtFk7fMoCNoYBdBtcaLnTJQjLI=";
  };

  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [ typing-extensions ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Binary Data manipulation, for humans";
    homepage = "https://github.com/guillp/binapy";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
