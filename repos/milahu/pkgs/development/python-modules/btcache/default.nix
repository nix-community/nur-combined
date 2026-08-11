{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  setuptools,
  wheel,
  requests,
  libtorrent-rasterbar,
}:

buildPythonApplication rec {
  pname = "btcache";
  version = "unstable-2025-10-30";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "btcache-py";
    rev = "e06403a84b16b7e82b4c73d872f2b504ccbcc6ae";
    hash = "sha256-XCiunGrlSOROG3Kwfk5rss5wAwxqxb3YDMRsshfLHzM=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    requests
    libtorrent-rasterbar
  ];

  pythonImportsCheck = [
    "btcache"
  ];

  meta = {
    description = "A caching BitTorrent proxy for hidden seeders, written in Python";
    homepage = "https://github.com/milahu/btcache-py";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "btcache";
  };
}
