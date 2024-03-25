{ lib
, python3
}:

python3.pkgs.buildPythonPackage rec {
  pname = "js2py";
  version = "0.74";

  # build from source hangs
  /*
    src = python3.pkgs.fetchPypi {
      pname = "Js2Py";
      inherit version;
      sha256 = "sha256-pBsQCd0UmK59Q2v6WslSoIypKku54x3Kbou5ZrSff84=";
    };
    */
  format = "wheel";
  src = python3.pkgs.fetchPypi rec {
    pname = "Js2Py";
    inherit version format;
    sha256 = "sha256-QKUIp54vjWJOPy5gT5Ch5vRqx1tBbX9HRZOf9KLpXgk=";
    dist = python;
    python = "py3";
  };

  # fix: SyntaxWarning: "is" with a literal
  # https://github.com/PiotrDabkowski/Js2Py/pull/284
  #postPatch = ''
  #  sed -i "s/ or g is 'OP_CODE':$/ or g == 'OP_CODE':/" js2py/internals/opcodes.py
  #'';

  buildInputs = (with python3.pkgs; [
    six
  ]);

  propagatedBuildInputs = (with python3.pkgs; [
    pyjsparser
    tzlocal
  ]);

  checkInputs = with python3.pkgs; [
  ];

  meta = with lib; {
    homepage = "https://github.com/PiotrDabkowski/Js2Py";
    description = "JavaScript to Python Translator & JavaScript interpreter written in 100% pure Python";
    license = licenses.mit;
  };
}
