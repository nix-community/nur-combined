# <https://ollama.com/library/gemma3n> (e2b, e4b)
# released 2025-06-20 (ish)
# features selective activation; e2b activates 2b parameters per eval, but _contains_ many more.
{ mkOllamaModel }: mkOllamaModel {
  modelName = "gemma3n";
  variant = "e4b";
  manifestHash = "sha256-Fcs5/ZOU/SVJ9t+Qgc/ITdE07PLJxb6RHlYpkgSJrDI=";
  modelBlob = "38e8dcc30df4eb0e29eaf5c74ba6ce3f2cd66badad50768fc14362acfb8b8cb6";
  modelBlobHash = "sha256-OOjcww306w4p6vXHS6bOPyzWa62tUHaPwUNirPuLjLY=";
}
