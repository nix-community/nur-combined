{
  lib,
  pkgs,
  buildPythonPackage,
}:
buildPythonPackage rec {
  pname = "xontrib-superfile";
  version = "0.0.5";

  src = pkgs.fetchFromGitHub {
    owner = "TechnoStrife";
    repo = "xontrib-superfile";
    rev = "09b8cfa1eda367a3ae0f462a6d9269df61231b59";
    sha256 = "sha256-ztaK99wHnVNp/rLeJZ1GA7plLKod07fylZTsQUpNpQw=";
  };

  doCheck = false;

  format = "pyproject";

  nativeBuildInputs = with pkgs.python3Packages; [
      build
      pdm-backend
  ];

  postPatch = ''
    sed -ie "/xonsh.*=/d" pyproject.toml
  '';
  
  meta = with lib; {
    description = "[superfile](https://github.com/yorukot/superfile) support function in the [xonsh shell](https://xon.sh).";
    homepage = "https://github.com/TechnoStrife/xontrib-superfile";
    license = licenses.mit;
  };
}

