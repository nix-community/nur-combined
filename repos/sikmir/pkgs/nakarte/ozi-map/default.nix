{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  maprec,
}:

python3Packages.buildPythonPackage {
  pname = "ozi-map";
  version = "0-unstable-2022-08-05";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "ozi_map";
    rev = "abd9e86d621ef5de89986e92b9e97e54b3173af4";
    hash = "sha256-leYn+Z0BLptvtmHglwvmhzjHUZh0XEZ9LEBQHDCjfNc=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail " @ git+https://github.com/wladich/maprec.git" ""
  '';

  dependencies = with python3Packages; [
    maprec
    pyproj
  ];

  doCheck = false;

  pythonImportsCheck = [ "ozi_map" ];

  meta = {
    description = "Python module for reading OziExplorer .map files";
    homepage = "https://github.com/wladich/ozi_map";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
