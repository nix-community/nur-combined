{
  python3,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "sane-lib-ssdp";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.setuptoolsBuildHook
  ];
  nativeCheckInputs = [
    python3.pkgs.pythonImportsCheckHook
  ];

  pythonImportsCheck = [
    "sane_ssdp"
  ];
  doCheck = true;
  strictDeps = true;
}
