{
  lib,
  python3Packages,
  fetchFromGitHub,

  searxng,
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "searxng-bm25-reranker";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "Oaklight";
    repo = "searxng-bm25-reranker";
    rev = "v${finalAttrs.version}";
    hash = "sha256-56tp7DMw8sZ6dSnKQ6DDeetWcOhOs6WS3bwlsbIAtxM=";
  };

  pyproject = true;
  build-system = with python3Packages; [ setuptools ];

  meta = {
    description = "BM25 reranking plugin for SearXNG using zero-dependency sparse search";
    homepage = "https://github.com/Oaklight/searxng-bm25-reranker";
    license = lib.licenses.agpl3Plus;
    inherit (searxng.meta) platforms;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
