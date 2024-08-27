{ python3Packages
, generated
, beets
, lib
}:

with python3Packages;
buildPythonPackage rec {
  format = "pyproject";

  inherit (generated) pname version src;

  nativeBuildInputs = [
    beets
    poetry-core
  ];

  # pythonImportsCheck = [ "beetsplug.filetote" ];

  meta = {
    description = "A plugin for beets that moves non-music files during the import process.";
    homepage = "https://github.com/gtronset/beets-filetote/";
    license = lib.licenses.mit;
  };
}

