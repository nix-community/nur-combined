{ pkgs }:

let
  python3Packages = pkgs.python3Packages;

  pytodotxt = python3Packages.buildPythonPackage rec {
    pname = "pytodotxt";
    version = "3.1.0";
    format = "pyproject";

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-AO1+bKIqjX3A+PDDQkdlIJ0ggIp2wGljocQ9kXUG5f4=";
    };

    nativeBuildInputs = [
      python3Packages.setuptools
      python3Packages.wheel
    ];

    # Patch pyproject.toml license format for older setuptools compatibility
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace 'license = "MIT"' 'license = {text = "MIT"}'
    '';

    pythonImportsCheck = [ "pytodotxt" ];
  };

  cursedspace = python3Packages.buildPythonPackage rec {
    pname = "cursedspace";
    version = "1.5.2";
    format = "pyproject";

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-IQQ/gEmNuaedXuG7UiKf0orYhxo2BgHI+RIP+drcKuw=";
    };

    nativeBuildInputs = [
      python3Packages.setuptools
      python3Packages.wheel
    ];

    pythonImportsCheck = [ "cursedspace" ];
  };
in
python3Packages.buildPythonApplication rec {
  pname = "pter";
  version = "3.23.0";
  pyproject = true;

  src = pkgs.fetchPypi {
    inherit pname version;
    hash = "sha256-kc23re+WJD7agwGFFRMj+nKfSX2uKzwtlkHmlPdh5Gw=";
  };

  build-system = [
    python3Packages.setuptools
    python3Packages.wheel
    python3Packages.docutils
  ];

  dependencies = [
    pytodotxt
    cursedspace
  ];

  # Patch pyproject.toml license format for older setuptools compatibility
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'license = "MIT"' 'license = {text = "MIT"}'
  '';

  pythonImportsCheck = [ "pter" ];

  meta = with pkgs.lib; {
    description = "Console UI to manage your todo.txt file(s)";
    homepage = "https://codeberg.org/pter/pter";
    license = licenses.mit;
    mainProgram = "pter";
  };
}
