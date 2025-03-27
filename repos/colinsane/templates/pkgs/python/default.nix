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
    # python3.pkgs.eggUnpackHook
    # python3.pkgs.eggBuildHook
    # python3.pkgs.eggInstallHook

    # python3.pkgs.hatch-fancy-pypi-readme
    # python3.pkgs.hatch-vcs
    # python3.pkgs.hatchling

    # python3.pkgs.poetry-core

    # python3.pkgs.pypaBuildHook
    # python3.pkgs.pypaInstallHook  # pretty much always want this (even if using setuptoolsBuildHook)
    # python3.pkgs.setuptoolsBuildHook  # if project has `setup.py`
    python3.pkgs.wrapPython
  ];

  propagatedBuildInputs = [
    # other python modules this depends on, if this package is supposed to be importable
  ];

  nativeCheckInputs = [
    # python3.pkgs.pytestCheckHook
    # python3.pkgs.pythonImportsCheckHook  #< or put in `nativeInstallCheckInputs` and set `doInstallCheck = true;`
  ];

  pythonImportsCheck = [
    # "mymodule"
  ];

  doCheck = true;

  meta = with lib; {
    # homepage = "https://example.com";
    # description = "python template project";
    maintainers = with maintainers; [ colinsane ];
  };
})
