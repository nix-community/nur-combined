{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "large-image";
  version = "1.14.3";

  src = fetchFromGitHub {
    owner = "girder";
    repo = "large_image";
    rev = "v${version}";
    hash = "sha256-8vixBAWwg2QzzWlhbXNAKk9rmla/LLZSdORRKm/IVBk=";
  };

  nativeBuildInputs = with python3Packages; [ setuptools-scm ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  propagatedBuildInputs = with python3Packages; [ cachetools palettable pillow psutil numpy ];

  doCheck = false;

  meta = with lib; {
    description = "Python modules to work with large multiresolution images";
    homepage = "http://girder.github.io/large_image/";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
