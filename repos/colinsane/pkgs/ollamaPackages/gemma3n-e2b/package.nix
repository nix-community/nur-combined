# <https://ollama.com/library/gemma3n> (e2b, e4b)
# released 2025-06-20 (ish)
# features selective activation; e2b activates 2b parameters per eval, but _contains_ many more.
{ mkOllamaModel }: mkOllamaModel {
  modelName = "gemma3n";
  variant = "e2b";
  manifestHash = "sha256-cZNy+Mfe7hiIIaTcuvde+hOjQtfoinnU/CQSsklH9v0=";
  modelBlob = "3839a254cf2d00b208c6e2524c129e4438f9d106bba4c3fbc12b631f519d1de1";
  modelBlobHash = "sha256-ODmiVM8tALIIxuJSTBKeRDj50Qa7pMP7wStjH1GdHeE=";
}
