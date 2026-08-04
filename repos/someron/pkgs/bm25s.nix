{
  lib,
  python3,
  fetchFromGitHub,
}:
let
  python = python3;
  pname = "bm25s";
  version = "0.3.9";
  sha256 = "sha256-/aIQCJnOInjaxRTbAJgYMs20zEayWLz+uBKGhqX5ULM=";
in
python.pkgs.buildPythonPackage {
  inherit pname version;


  env = {
    BM25S_VERSION = version;
  };

  src = fetchFromGitHub {
    owner = "xhluca";
    repo = pname;
    rev = version;
    inherit sha256;
  };

  meta = {
    description = "Fast BM25 search in Python, powered by Numpy and Numba";
    homepage = "https://github.com/xhluca/bm25s";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };

  pyproject = true;

  build-system = with python.pkgs; [ setuptools ];

  dependencies = with python.pkgs; [
    orjson
    tqdm
    pystemmer
    numba
  ];
}