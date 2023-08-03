{ lib
, python3
, fetchPypi
}:

python3.pkgs.buildPythonApplication rec {
  pname = "flask-compress";
  version = "1.13";
  format = "pyproject";

  src = fetchPypi {
    pname = "Flask-Compress";
    inherit version;
    hash = "sha256-7pbxi/mwDy3rTjQGykoFCTqoDi7wV4Ulo7TTLs3/Ep0=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.setuptools-scm
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    brotli
    flask
  ];

  pythonImportsCheck = [ "flask_compress" ];

  meta = with lib; {
    description = "Compress responses in your Flask app with gzip, deflate or brotli";
    homepage = "https://pypi.org/project/flask-compress";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
