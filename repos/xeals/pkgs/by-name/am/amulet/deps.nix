{ lib
, fetchPypi
, buildPythonPackage
  # Package dependencies
, zlib
  # Python dependencies
, setuptools
, cython
, lz4
, mutf8
, numpy_1
, pillow
, platformdirs
, portalocker
, versioneer
, distutils
}:

let
  build-system = [
    setuptools
    cython
    versioneer
    numpy_1
  ];

  platformdirs31 = platformdirs.overrideAttrs (old: {
    src = fetchPypi {
      pname = "platformdirs";
      version = "3.1.1";
      hash = "sha256-AkmWVJ7ojsGpqpn/f4/IGbtZ4sNHe0ENkKFtMtbnB6o=";
    };
  });

  amulet-core = buildPythonPackage rec {
    pname = "amulet-core";
    version = "1.9.35";
    src = fetchPypi {
      pname = "amulet_core";
      inherit version;
      hash = "sha256-JreloREOJ2FGtYDmhrZUMIIXlS+nSrML6ONP98Mc7tI=";
    };

    pyproject = true;
    inherit build-system;

    dependencies = [
      amulet-leveldb
      amulet-nbt
      lz4
      platformdirs31
      pymctranslate

      ((portalocker.overrideAttrs (old: {
        src = fetchPypi {
          pname = "portalocker";
          version = "2.4.0";
          hash = "sha256-pkitdhuOonNwy1kVNQEizYB7gg0hk+1cnMKPFj32N/Q=";
        };
      })).overridePythonAttrs (old: {
        doCheck = false;
      }))
    ];
  };

  amulet-leveldb = buildPythonPackage rec {
    pname = "amulet-leveldb";
    version = "1.0.2";
    src = fetchPypi {
      pname = "amulet_leveldb";
      inherit version;
      hash = "sha256-s6pRHvcb9rxrIeljlb3tDzkrHcCT71jVU1Bn2Aq0FUE=";
    };

    pyproject = true;
    inherit build-system;
    buildInputs = [ zlib ];

    dependencies = [ lz4 ];
  };

  amulet-nbt = buildPythonPackage rec {
    pname = "amulet-nbt";
    version = "2.1.5";
    src = fetchPypi {
      pname = "amulet_nbt";
      inherit version;
      hash = "sha256-qyM3PvslGZOlJjgTEeXyXNy1oz7jc6eFGYczVD3vuxc=";
    };

    pyproject = true;
    inherit build-system;

    dependencies = [ mutf8 ];
  };

  pymctranslate = buildPythonPackage rec {
    pname = "pymctranslate";
    version = "1.2.36";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-XQmDu+5GnaWgHJrfO86Ndwi7GgNUtWPBN4Y10JAa97A=";
    };

    pyproject = true;
    inherit build-system;

    dependencies = [ amulet-nbt ];
  };

  minecraft-resource-pack = buildPythonPackage rec {
    pname = "minecraft-resource-pack";
    version = "1.4.6";
    src = fetchPypi {
      pname = "minecraft_resource_pack";
      inherit version;
      hash = "sha256-ZBl0r+Nxwf1hl51a17WZEXUeFFq5a08kUeD4VSI2Rhk=";
    };

    pyproject = true;
    inherit build-system;
    dependencies = [
      pillow
      amulet-nbt
      platformdirs31
    ];
  };

  # (buildPythonPackage {
  #   pname = "minecraft-model-reader";
  #   version = "";
  #   src = fetchPypi {
  #     pname = "amulet-nbt";
  #     version = "2.0.6";
  #     hash = "";
  #   };
  # })
in

{
  inherit
    amulet-core
    amulet-leveldb
    amulet-nbt
    pymctranslate
    minecraft-resource-pack
    platformdirs31
    ;
}
