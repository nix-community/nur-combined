{ lib, stdenv, python3Packages, fetchFromGitHub, thinplatespline }:

python3Packages.buildPythonPackage rec {
  pname = "maprec";
  version = "2022-08-06";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "maprec";
    rev = "3332183a8010bceba564078cdb05ab6c02ac852e";
    hash = "sha256-2V1n6XEXPePA5YB8dKlBgTtbL2/2qG2KBdsHbekETXE=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace " @ git+https://github.com/wladich/thinplatespline.git" ""
  '';

  propagatedBuildInputs = with python3Packages; [ pyyaml pyproj thinplatespline ];

  doCheck = false;

  pythonImportsCheck = [ "maprec" ];

  meta = with lib; {
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
  };
}
