# released 2025-08-08
# <https://unsloth.ai/blog/gpt-oss>
# <https://unsloth.ai/docs/models/gpt-oss-how-to-run-and-fine-tune>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/unsloth/gpt-oss-20b-GGUF";
  rootDir = "gpt-oss-20b-Q4_K_M.gguf";
  name = "gpt-oss-20b-Q4_K_M.gguf";
  fetchLFS = true;
  rev = "ce6ba6163271f5d73dbe2a20b85e66d79126e942";
  hash = "sha256-JXJ0QVF7wHEGs3Bv/lGWJxr3tR8tPEnxBULNYfghCys=";
}
