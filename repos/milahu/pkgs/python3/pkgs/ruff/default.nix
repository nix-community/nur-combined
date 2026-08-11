{ lib
, buildPythonPackage
, hatchling
, pkgs-ruff
}:

buildPythonPackage rec {
  inherit (pkgs-ruff) pname version src meta;
  pyproject = true;

  nativeBuildInputs = [
    hatchling
  ];

  # dont build the rust project here
  # https://hatch.pypa.io/latest/config/build/#packages
  postPatch = ''
    sed -i \
    's/^requires = \["maturin.*/requires = ["hatchling"]/;'\
    's/^build-backend = "maturin"/build-backend = "hatchling.build"/;'\
    's|^\[tool.maturin\]|[tool.hatch.build.targets.wheel]\npackages = ["python/ruff"]\n\n&|;'\
    "" pyproject.toml

    sed -i 's|def find_ruff_bin() -> str:|&\n    return "${pkgs-ruff}/bin/ruff"|' python/ruff/__main__.py
  '';

  propagatedBuildInputs = [
    pkgs-ruff
  ];

  pythonImportsCheck = [ "ruff" ];
}
