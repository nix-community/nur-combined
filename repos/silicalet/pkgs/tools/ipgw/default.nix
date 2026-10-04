{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "NEU-ipgw-manager";
  version = "3.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Neboer";
    repo = "ipgw-py-manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h+p/xNtYarew/A2RztV/rnsebIfdLFXgt1U3pF6xDCs=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    beautifulsoup4
    platformdirs
    requests
    tabulate
    wcwidth
  ];

  pythonImportsCheck = [ "ipgw" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI manager for the Northeastern University network gateway";
    homepage = "https://github.com/Neboer/ipgw-py-manager";
    changelog = "https://github.com/Neboer/ipgw-py-manager/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "ipgw";
    platforms = lib.platforms.all;
  };
})
