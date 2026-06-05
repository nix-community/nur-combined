# released 2026-03-12
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/Tesslate/OmniCoder-9B-GGUF";
  rootDir = "omnicoder-9b-q4_k_m.gguf";
  name = "omnicoder-9b-q4_k_m.gguf";
  fetchLFS = true;
  rev = "c06117a99179f36962d782946970726b9fc9e533";
  hash = "sha256-xTAFR2GzhUOIJ0LrSlL9Qry3cT15KdJ54JtjuaiaJcM=";
}
