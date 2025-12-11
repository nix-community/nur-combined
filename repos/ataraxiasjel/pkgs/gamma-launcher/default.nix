{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  pythonOlder,
  setuptools,
  beautifulsoup4,
  cloudscraper,
  gitpython,
  platformdirs,
  py7zr,
  python-unrar,
  requests,
  tenacity,
  tqdm,
  unrar,
  nix-update-script,
}:
buildPythonApplication rec {
  pname = "gamma-launcher";
  version = "2.6";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "Mord3rca";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-QegptRWMUKpkzsHBdT6KlyyWpmrIuvcyCRvWT9Te3DQ=";
  };

  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    cloudscraper
    gitpython
    platformdirs
    py7zr
    python-unrar
    requests
    tenacity
    tqdm
  ];

  makeWrapperArgs = [ "--set UNRAR_LIB_PATH ${unrar}/lib/libunrar.so" ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Just another Launcher to setup S.T.A.L.K.E.R.: G.A.M.M.A.";
    homepage = "https://github.com/Mord3rca/gamma-launcher";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "gamma-launcher";
  };
}
