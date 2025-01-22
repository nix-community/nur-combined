{
  lib,
  fetchPypi,
  python3,
  testers,
  iteround ? python3.pkgs.callPackage ./iteround.nix { },
  pythonRelaxDepsHook ? python3.pkgs.pythonRelaxDepsHook,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "flameshow";
  version = "1.1.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-EsskI5qgSHuBzmqyEfPgLb1YiXvQyRiEFVGxEUiDH6A=";
  };

  nativeBuildInputs = [
    pythonRelaxDepsHook
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    click
    typing-extensions
    textual
    protobuf4
    iteround
  ];

  pythonRelaxDeps = [
    "iteround"
  ];

  passthru.tests.version = testers.testVersion {
    package =
      # a substitute for `finalAttrs.package`
      (python3.pkgs.callPackage ./flameshow.nix { });
  };

  pythonImportsCheck = [ "flameshow" ];

  meta = with lib; {
    description = "A terminal Flamegraph viewer";
    homepage = "https://github.com/laixintao/flameshow";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "flameshow";
  };
}
