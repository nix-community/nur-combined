{ lib
, buildPythonPackage
, setuptools
, rope_1_10
, omnimotion
, prefix-python-modules
}:

let
  pyproject = builtins.fromTOML (builtins.readFile ./pyproject.toml);
in
buildPythonPackage {
  pname = pyproject.project.name;
  version = pyproject.project.version;
  pyproject = true;

  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    setuptools
  ];
  propagatedBuildInputs = [
    rope_1_10
    setuptools # pkg_resources for rope
  ];

  passthru.tests = { inherit omnimotion; };

  meta = with lib; {
    description = pyproject.project.description;
    homepage = "https://github.com/SomeoneSerge/pkgs";
    license = licenses.mit;
    mainProgram = pyproject.project.name;
    maintainers = with maintainers; [ SomeoneSerge ];
    platforms = platforms.all;
  };
}
