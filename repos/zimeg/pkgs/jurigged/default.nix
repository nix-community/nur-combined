{ lib
, pkgs
}:

let
  codefind = pkgs.python3.pkgs.buildPythonPackage {
    pname = "codefind";
    version = "0.1.6";
    format = "pyproject";

    src = pkgs.fetchFromGitHub {
      owner = "breuleux";
      repo = "codefind";
      rev = "v0.1.6";
      sha256 = "sha256-jSAOlxHpi9hjRJjfj9lBpbgyEdiBCI7vVZ/RXspPbgc=";
    };

    buildInputs = [
      pkgs.python311Packages.poetry-core
    ];

    meta = with lib; {
      description = "Find code objects and their referents";
      homepage = "https://github.com/breuleux/codefind";
      changelog = "https://github.com/breuleux/codefind/releases/tag/v${version}";
      license = licenses.mit;
      maintainers = [ ];
    };
  };

  ovld = pkgs.python3.pkgs.buildPythonPackage {
    pname = "ovld";
    version = "0.3.5";
    format = "pyproject";

    src = pkgs.fetchFromGitHub {
      owner = "breuleux";
      repo = "ovld";
      rev = "v0.3.5";
      sha256 = "sha256-2s24I6CMldGJjneRFYuHTUAjdd+q//ABWiS8vR9pW1s=";
    };

    buildInputs = [
      pkgs.python311Packages.poetry-core
    ];

    meta = with lib; {
      description = "Advanced multiple dispatch for Python functions";
      homepage = "https://github.com/breuleux/ovld";
      changelog = "https://github.com/breuleux/ovld/releases/tag/v${version}";
      license = licenses.mit;
      maintainers = [ ];
    };
  };
in
pkgs.python3.pkgs.buildPythonApplication {
  pname = "jurigged";
  version = "0.5.8";
  format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "breuleux";
    repo = "jurigged";
    rev = "v0.5.8";
    sha256 = "sha256-XlImCnBpr/PjqEPFIpQfe1fWZcbM1btupikz2ab0vyI=";
  };

  dependencies = [
    pkgs.python3Packages.blessed
    codefind
    ovld
    pkgs.python3Packages.poetry-core
    pkgs.python3Packages.watchdog
  ];

  meta = with lib; {
    description = "Hot reloading for Python";
    homepage = "https://github.com/breuleux/jurigged";
    changelog = "https://github.com/breuleux/jurigged/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [ ];
  };
}
