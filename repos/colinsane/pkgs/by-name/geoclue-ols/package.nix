{
  lib,
  fetchFromGitea,
  fastcluster,
  python3,
  stdenvNoCC,
}: stdenvNoCC.mkDerivation {
  pname = "ols";
  version = "0.1.0-unstable-2024-06-30";
  format = "pyproject";

  src = fetchFromGitea {
    # my dev branch has a few changes:
    # - fix `cellid-ols-import` to make --mcc, --mnc actually be optional
    # - synthesize cell locations when no exact match is found
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "ols";
    rev = "5bb577d50fda0442635f254bf9fc25f1a7700295";
    hash = "sha256-0HitMOBcc1Zn8vQroVM4qXkoGFiXJxWAsqPYIEfUXH8=";
  };
  # src = fetchFromGitea {
  #   domain = "codeberg.org";
  #   owner = "tpikonen";
  #   repo = "ols";
  #   rev = "069560accc6558f16d6d9abea63bd7563ea3f0e9";
  #   hash = "sha256-/931fc37QzITOA61D2CeXr/JmvDg0t8fLSt2y+2kSyQ=";
  # };
  # src = /home/colin/ref/repos/tpikonen/ols;

  propagatedBuildInputs = with python3.pkgs; [
    aiohttp
    fastcluster
    fastjsonschema
    mercantile
    numpy
    scipy
    typing-extensions
  ];

  nativeBuildInputs = [
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.setuptoolsBuildHook
    python3.pkgs.wrapPython
  ];
  nativeCheckInputs = [
    python3.pkgs.pythonImportsCheckHook
  ];

  postFixup = ''
    wrapPythonPrograms
  '';

  postInstallCheck = ''
    $out/bin/ols --help
  '';

  pythonImportsCheck = [
    "ols"
  ];

  doCheck = true;
  doInstallCheck = true;
  strictDeps = true;

  meta = with lib; {
    homepage = "https://codeberg.org/tpikonen/ols";
    description = "HTTP location service with Mozilla Location Service (MLS) compatible API";
    maintainers = with maintainers; [ colinsane ];
  };
}
