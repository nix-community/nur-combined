{ lib
, python3Packages
, fetchFromGitHub 
}:

python3Packages.buildPythonPackage rec {
  pname = "merge-keepass";
  version = "2023-07-11";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "merge-keepass";
    rev = "a3681fc3ee9e4ec59bbbacd447672f9f9115103e";
    sha256 = "sha256-YS1OXxigl+ijtw31MLAp0oKxTEC+7q+3NnKZlQDEvn8=";
  };

  nativeBuildInputs = with python3Packages; [ pytest ];
  propagatedBuildInputs = with python3Packages; [ pykeepass click dateutils ];
  checkInputs = with python3Packages; [ pytest ];

  checkPhase = ''
    pytest tests.py
  '';

  doCheck = true;

  meta = with lib; {
    description = "Keepass Databases Merging script";
    homepage = "http://github.com/SCOTT-HAMILTON/merge-keepass";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
