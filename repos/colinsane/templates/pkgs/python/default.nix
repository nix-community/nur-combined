{
  lib,
  fetchFromGitHub,
  python3,
  stdenv,
}: stdenv.mkDerivation (finalAttrs: {
  # pname = "mypackage";
  # version = "0.1-unstable-2024-06-04";

  src = fetchFromGitHub {
    # owner = "owner";
    # repo = "repo";
    rev = "v${finalAttrs.version}";
    # hash = "";
  };

  postFixup = ''
    wrapPythonPrograms
  '';

  nativeBuildInputs = [
    # python3.pkgs.poetry-core
    # python3.pkgs.pypaBuildHook
    # python3.pkgs.pypaInstallHook
    # python3.pkgs.pythonImportsCheckHook
    python3.pkgs.wrapPython
  ];

  propagatedBuildInputs = [
    # other python modules this depends on, if this package is supposed to be importable
  ];

  nativeCheckInputs = [
    # python3.pkgs.pytestCheckHook
  ];

  pythonImportsCheck = [
    # "mymodule"
  ];

  meta = with lib; {
    # homepage = "https://example.com";
    # description = "python template project";
    maintainers = with maintainers; [ colinsane ];
  };
})
