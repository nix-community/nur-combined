{ python3Packages
, generated
, beets
, lib
}:

with python3Packages;
buildPythonPackage rec {
  pyproject = true;

  inherit (generated) pname version src;

  build-system = [ poetry-core ];

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail "poetry-core<2.0.0" "poetry-core"
  '';

  nativeBuildInputs = [ beets ];

  # pythonImportsCheck = [ "beetsplug.filetote" ];

  meta = {
    description = "A plugin for beets that moves non-music files during the import process.";
    homepage = "https://github.com/gtronset/beets-filetote/";
    license = lib.licenses.mit;
  };
}

