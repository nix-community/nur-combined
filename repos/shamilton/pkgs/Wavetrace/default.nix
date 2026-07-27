{ lib
, buildPythonPackage
, python3Packages
, fetchFromGitHub 

, splat

, imagemagick_light
}:

buildPythonPackage rec {
  pname = "wavetrace";
  version = "4.0.3";

  src = fetchFromGitHub {
    owner = "NZRS";
    repo = "wavetrace";
    rev = "v${version}";
    sha256 = "07j283x50y26hddlvnvwjsqczsy1lr9wg7f5xjb3hypfp5fm80gh";
  };

  patches = [ ./fix-geoideval-request.patch ];

  propagatedBuildInputs = with python3Packages; [
    certifi
    chardet
    click
    gdal
    idna
    requests
    shapely
    splat
    urllib3
  ];
  buildInputs = with python3Packages; [ setuptools ];
  pyproject = true;

  checkInputs = with python3Packages; [ splat gdal imagemagick_light ];
  
  # Needs internet
  doCheck = false;

  meta = with lib; {
    description = "Radio propagation modelling";
    homepage = "https://github.com/NZRS/wavetrace";
    license = licenses.agpl3Only;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
