{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
}:

buildPythonPackage rec {
  pname = "nixpkgs-pytools";
  version = "unstable-2023-11-02";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixpkgs-pytools";
    rev = "70c7b9db33ea5e31d35d0b67c9171757e4d74bd0";
    hash = "sha256-rzF9IIWr2Gjf0l3YgxX+A0ifkl3r1kXbfsSPQlekJ7s=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [ "nixpkgs_pytools" ];

  meta = with lib; {
    description = "Tools for removing the tedious nature of creating nixpkgs derivations [maintainer=@costrouc";
    homepage = "https://github.com/nix-community/nixpkgs-pytools";
    changelog = "https://github.com/nix-community/nixpkgs-pytools/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
