{ lib, fetchPypi, python3, testers, flameshow, iteround }:

python3.pkgs.buildPythonPackage rec {
  pname = "flameshow";
  version = "1.1.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-lVDJfm4VPwJ360BuF3olBKmt2WUd91dbZPfRrcPE4W8=";
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

  pythonImportsCheck = [ "flameshow" ];

  meta = with lib; {
    description = "A terminal Flamegraph viewer";
    homepage = "https://github.com/laixintao/flameshow";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "flameshow";
  };
}
