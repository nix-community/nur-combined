{
  lib,
  fetchFromGitHub,
  python3,
  stdenv,
}: stdenv.mkDerivation (finalAttrs: {
  pname = "depthcharge-tools";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "alpernebbi";
    repo = "depthcharge-tools";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3xPRNDUXLOwYy8quMfYSiBfzQl4peauTloqtZBGbvlw=";
  };

  nativeBuildInputs = [
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.wrapPython
  ];

  propagatedBuildInputs = with python3.pkgs; [
    setuptools  #< needs `pkg_resources` at runtime
  ];

  nativeCheckInputs = [
    python3.pkgs.pythonImportsCheckHook
  ];

  postFixup = ''
    wrapPythonPrograms
  '';

  pythonImportsCheck = [
    "depthcharge_tools"
  ];

  doCheck = true;
  strictDeps = true;

  meta = with lib; {
    homepage = "https://github.com/alpernebbi/depthcharge-tools";
    description = "Tools to manage the Chrome OS bootloader";
    maintainers = with maintainers; [ colinsane ];
  };
})
