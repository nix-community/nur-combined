{ lib, stdenv, python3Packages, fetchFromGitHub, maprec }:

python3Packages.buildPythonPackage rec {
  pname = "ozi_map";
  version = "2022-08-05";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "ozi_map";
    rev = "abd9e86d621ef5de89986e92b9e97e54b3173af4";
    hash = "sha256-leYn+Z0BLptvtmHglwvmhzjHUZh0XEZ9LEBQHDCjfNc=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace " @ git+https://github.com/wladich/maprec.git" ""
  '';

  propagatedBuildInputs = with python3Packages; [ maprec pyproj ];

  doCheck = false;

  pythonImportsCheck = [ "ozi_map" ];

  meta = with lib; {
    description = "Python module for reading OziExplorer .map files";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
  };
}
