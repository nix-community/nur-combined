{ lib
, fetchPypi
, python312
, zlib
}:

let
  python = python312;
  inherit (python.pkgs)
    buildPythonApplication
    buildPythonPackage
    setuptools
    cython
    numpy_1
    pillow
    pyopengl
    pyopengl-accelerate
    versioneer
    wxpython
    ;

  build-system = [
    setuptools
    cython
    versioneer
    numpy_1
  ];

  deps = python.pkgs.callPackage ./deps.nix { };
  inherit (deps)
    amulet-core
    amulet-nbt
    minecraft-resource-pack
    platformdirs31
    ;
in

buildPythonApplication rec {
  pname = "amulet-map-editor";
  version = "0.10.48";
  src = fetchPypi {
    pname = "amulet_map_editor";
    inherit version;
    hash = "sha256-CWXutx9m/N8EZ0tNtPE61sjh5gQ1qb9gLixezonFrsY=";
  };

  pyproject = true;
  inherit build-system;

  dependencies = [
    amulet-core
    amulet-nbt
    minecraft-resource-pack
    pillow
    platformdirs31
    pyopengl
    pyopengl-accelerate

    (wxpython.overridePythonAttrs (prev: {
      propagatedBuildInputs =
        lib.filter (p: p.pname != "numpy") prev.propagatedBuildInputs
        ++ [ numpy_1 ];
    }))

  ];

  meta.mainProgram = "amulet_map_editor";
}
