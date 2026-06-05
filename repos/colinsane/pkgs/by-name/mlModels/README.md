## machine learning models
source from:
- <https://huggingface.co/ggml-org>
- <https://huggingface.co/models?library=gguf&sort=trending>
- <https://unsloth.ai/docs>


## tooling
- `hf` CLI tool
  - download whole model directories like `hf download xai-org/grok-2 --local-dir /local/grok-2`
- `fetchgit { fetchLFS = true; rootDir = ...; }`
  - nixpkgs has a few fetchgit `url = "https://huggingface.co/...";` callers
  - it's likely that split gguf files "just work"?


## formats
- llama-cpp is known to be compatible with:
  - [x] gguf
  - [x] llamafile (obsolete)


## quantization
- `Q4`: 4 bits per weight
- `Q4_K`: 4 bits per weight, but with k-means clustering.
  - weights are grouped into superblocks of 8 or 16.
  - each superblock has a single scale (usually 6 bit quantized?), and each weight within it is multiplied by it during expansion.
- `Q4_K_{S,M,L}`: variants on `Q4_K` optimized for Small, Medium, or Large models.
...
- K-type quantizations introduced here: <https://github.com/ggml-org/llama.cpp/pull/1684>
  - "`GGML_TYPE_Q4_K`: type-1: 4-bit quantization in super-blocks containing 8 blocks, each block having 32 weights. Scales and mins are quantized with 6 bits. This ends up using 4.5 bpw."
  - "`LLAMA_FTYPE_MOSTLY_Q4_K_M` - uses `GGML_TYPE_Q6_K` for half of the attention.wv and `feed_forward.w2` tensors, else `GGML_TYPE_Q4_K`"

## brands
- Kimi
- MiniMax
- NVIDIA - Nemotron
- Phi
- Qwen
  - Alibaba
- Z.ai
  - <https://en.wikipedia.org/wiki/Z.ai>
  - <https://z.ai/model-api>
