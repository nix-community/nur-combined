{ python3Packages
, fetchFromGitHub
, beets
, lib
}:

with python3Packages;
buildPythonPackage rec {
  format = "pyproject";

  pname = "beets-filetote";
  version = "0.4.8";

  src = fetchFromGitHub {
    owner = "gtronset";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ve6druyiu4WJJI1RKc20AMHPARD0h84myg8CM9paZeM=";
  };

  nativeBuildInputs = [
    beets
    poetry-core
  ];

  pythonImportsCheck = [ "beetsplug.filetote" ];

  meta = {
    description = "A plugin for beets that moves non-music files during the import process.";
    homepage = "https://github.com/gtronset/beets-filetote/";
    license = lib.licenses.mit;
  };
}

