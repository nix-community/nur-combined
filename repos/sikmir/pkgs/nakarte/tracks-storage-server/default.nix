{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  msgpack,
  protobuf,
  psycopg2,
  setuptools,
}:

buildPythonPackage {
  pname = "tracks-storage-server";
  version = "0-unstable-2026-07-19";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "sikmir";
    repo = "tracks_storage_server";
    rev = "8d975293f884f0bb270e77690946ddf4e8a00a88";
    hash = "sha256-puFn9k5fL5dM1e5q3nl1m4xsceiXeT0vP3GTSzKE8Ho=";
  };

  postPatch = ''
    substitute config.py.example config.py --replace-fail "'password" "#'password"
  '';

  build-system = [ setuptools ];

  dependencies = [
    msgpack
    protobuf
    psycopg2
  ];

  pythonImportsCheck = [ "server" ];

  meta = {
    description = "Tracks storage server";
    homepage = "https://github.com/sikmir/tracks_storage_server";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
