{ python3Packages
, fetchFromGitHub
, beets
, lib
}:

with python3Packages;
buildPythonPackage rec {
  format = "pyproject";

  pname = "beets-filetote";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "gtronset";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-hJu+k9TIA3T8r4dTMiRJ/JC1TzbUFAC9RjoMRD/XdKU=";
  };

  nativeBuildInputs = [
    beets
    poetry-core
  ];

  prePatch = ''
    sed -i 's|mediafile = "0.10.0"|mediafile = "^0.10.0"|' pyproject.toml
  '';

  pythonImportsCheck = [ "beetsplug.filetote" ];

  meta = {
    description = "A plugin for beets that moves non-music files during the import process.";
    homepage = "https://github.com/gtronset/beets-filetote/";
    license = lib.licenses.mit;
  };
}

