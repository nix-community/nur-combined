{
  python3,
  stdenvNoCC,
  transmission_4,
}:
stdenvNoCC.mkDerivation {
  pname = "sane-lib-bt";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.setuptoolsBuildHook
  ];
  propagatedBuildInputs = [ transmission_4 ];
  nativeCheckInputs = [
    python3.pkgs.pythonImportsCheckHook
  ];

  pythonImportsCheck = [
    "sane_bt"
  ];
  doCheck = true;
  strictDeps = true;
}
