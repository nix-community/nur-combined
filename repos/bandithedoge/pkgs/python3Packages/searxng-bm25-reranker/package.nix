{
  sources,

  lib,
  python3Packages,

  searxng,
}:
python3Packages.buildPythonPackage {
  inherit (sources.searxng-bm25-reranker) pname src;
  version = lib.removePrefix "v" sources.searxng-bm25-reranker.version;
  pyproject = true;
  build-system = with python3Packages; [ setuptools ];

  meta = {
    description = "BM25 reranking plugin for SearXNG using zero-dependency sparse search";
    homepage = "https://github.com/Oaklight/searxng-bm25-reranker";
    license = lib.licenses.agpl3Plus;
    inherit (searxng.meta) platforms;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
