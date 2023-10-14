{ lib, fetchPypi, python3, testers, flameshow, iteround }:

python3.pkgs.buildPythonPackage rec {
  pname = "flameshow";
  version = "0.99.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Xwc3Y0Q7NucWAabD6tjl68Ib5rKiEmbjTJ6Py89Yfwc=";
  };

  nativeBuildInputs = with python3.pkgs; [ poetry-core ];

  propagatedBuildInputs = with python3.pkgs; [
    click
    typing-extensions
    textual
    protobuf
    iteround
  ];

  passthru.tests.version = testers.testVersion { package = flameshow; };

  meta = with lib; {
    description = "A terminal Flamegraph viewer";
    homepage = "https://github.com/laixintao/flameshow";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "flameshow";
  };
}
