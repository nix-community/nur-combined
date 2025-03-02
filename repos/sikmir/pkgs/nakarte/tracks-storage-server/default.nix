{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  writeText,
  msgpack,
  protobuf,
  psycopg2,
}:

let
  setupPy = writeText "setup.py" ''
    from setuptools import setup
    setup(
      name='tracks_storage_server',
      version='1.0',
      install_requires=['msgpack', 'protobuf', 'psycopg2'],
      py_modules=['server', 'nktk_raw_pb2', 'config'],
      data_files=[('bin', ['init.sql'])],
      scripts=['init_db.py'],
    )
  '';
in
buildPythonPackage {
  pname = "tracks-storage-server";
  version = "0-unstable-2024-04-27";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "tracks_storage_server";
    rev = "080526665a38c44e8c08e70d4ddcdda1c1911fc8";
    hash = "sha256-fN7OG52t2pHxFlCxhnMkVMpctsuwBQyuXMO9CD9eWLg=";
  };

  postPatch = ''
    cp ${setupPy} ${setupPy.name}
    substitute config.py.example config.py --replace-fail "'password" "#'password"
  '';

  dependencies = [
    msgpack
    protobuf
    psycopg2
  ];

  pythonImportsCheck = [ "server" ];

  meta = {
    description = "Tracks storage server";
    homepage = "https://github.com/wladich/tracks_storage_server";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
