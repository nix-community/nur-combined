## ollama model format
ollama API isn't documented anywhere, and it has changed over time, but it's alluded to in a few places.
1. it's similar to an "OCI registry".
2. mention of endpoint: <https://github.com/ollama/ollama/issues/6470>
- `https://registry.ollama.ai/v2/library/$model/manifests/$variant`

## choosing a model
### easy way:
- <https://ollama.com/library?sort=popular>

### social way:
- <https://www.reddit.com/r/LocalLLaMA/>

### for sensitive/illicit things ("Uncensored General Intelligence"):
- <https://www.reddit.com/r/LocalLLaMA/comments/1hk0ldo/december_2024_uncensored_llm_test_results/>
- search "abliterated" or "abliterate"
- search "uncensored"
- search "Eric Hartford" <https://erichartford.com/uncensored-models>

### leaderboards
- <https://huggingface.co/spaces/open-llm-leaderboard/open_llm_leaderboard>
  - specifically for locally-hosted models
- <https://lmarena.ai/leaderboard>
  - general purpose
  - user ranked
  - lacks details like model size, eval time, etc
- <https://eqbench.com/>
  - for code writing
- <https://evalplus.github.io/leaderboard.html>
  - for code writing
- <https://huggingface.co/spaces/mike-ravkine/can-ai-code-results>
  - for code writing
- <https://huggingface.co/spaces/DontPlanToEnd/UGI-Leaderboard>
  - for uncensored models


## recent model releases
- [ ] kimi-k2 (1026b)
  - released 2025-07-17
  - <https://ollama.com/huihui_ai/kimi-k2>
    - requires patching ollama (trivial)
  - <https://huggingface.co/moonshotai/Kimi-K2-Instruct>
  - Mixture-of-Experts, with 384 experts & 32B activated parameters
- [x] gemma3n (e2b, e4b)
  - released 2025-06-20 (ish)
  - <https://ollama.com/library/gemma3n>
- [x] mistral-small3.2 (24b)
  - released 2025-06-20
  - <https://ollama.com/library/mistral-small3.2>
- [x] magistral (24b)
  - released 2025-06-10
  - <https://ollama.com/library/magistral>
  - <https://mistral.ai/news/magistral>
- [x] devstral (24b)
  - released 2025-05-21
  - <https://ollama.com/library/devstral>
  - <https://mistral.ai/news/devstral>
- [ ] phi4-reasoning (14b)
  - released 2025-04-30
  - <https://ollama.com/library/phi4-reasoning>
  - <https://azure.microsoft.com/en-us/blog/one-year-of-phi-small-language-models-making-big-leaps-in-ai/>
- [x] phi4 (14b)
  - released 2025-04-30
  - <https://ollama.com/library/phi4>
  - <https://azure.microsoft.com/en-us/blog/one-year-of-phi-small-language-models-making-big-leaps-in-ai/>
- [x] qwen3 (0.6b, 1.7b, 4b, 8b, 14b, 30b, 32b, 235b)
  - released 2025-04-29
  - <https://ollama.com/library/qwen3>
  - <https://qwenlm.github.io/blog/qwen3/>
- [ ] granite3.3 (2b, 8b)
  - released 2025-04-16
  - <https://ollama.com/library/granite3.3>
- [ ] cogito (3b, 8b, 14b, 32b, 70b)
  - released 2025-04-08
  - <https://ollama.com/library/cogito>
  - <https://www.deepcogito.com/research/cogito-v1-preview>
- [ ] deepcoder (1.5b, 14b)
  - released 2025-04-07
  - <https://ollama.com/library/deepcoder>
  - <https://pretty-radio-b75.notion.site/DeepCoder-A-Fully-Open-Source-14B-Coder-at-O3-mini-Level-1cf81902c14680b3bee5eb349a512a51>
- [x] llama4 (16x17b, 128x17b)
  - released 2025-04-05
  - <https://ollama.com/library/llama4>
  - <https://ai.meta.com/blog/llama-4-multimodal-intelligence/>
- [ ] exaone-deep (2.4b, 7.8b, 32b)
  - released 2025-03-18
  - <https://ollama.com/library/exaone-deep>
- [ ] mistral-small3.1 (24b)
  - released 2025-03-17
  - <https://ollama.com/library/mistral-small3.1>
  - <https://mistral.ai/news/mistral-small-3-1>
- [x] gemma3 (1b, 4b, 12b, 27b)
  - released 2025-03-xx
  - <https://ollama.com/library/gemma3>
- [x] openthinker (7b, 32b)
  - released 2025-01-28
  - <https://ollama.com/library/openthinker>
  - <https://www.open-thoughts.ai/blog/launch>
- [x] dolphin3 (8b)
  - released 2024-12-29
  - <https://ollama.com/library/dolphin3>
- [x] olmo2 (7b, 13b)
  - released 2024-11-26
  - <https://ollama.com/library/olmo2>
  - <https://allenai.org/blog/olmo2>
- [x] orca-mini (3b, 7b, 13b, 70b)
  - released 2023-06-23
  - <https://ollama.com/library/orca-mini>


- [ ] dolphin-mixtral (8x7b, 8x22b)
  - Mixture-of-Experts
  - <https://ollama.com/library/dolphin-mixtral>
- [ ] deepseek-coder-v2 (16b, 236b)
  - Mixture-of-Experts
  - <https://ollama.com/library/deepseek-coder-v2>
- [ ] mixtral (8x7b, 8x22b)
  - Mixture-of-Experts
  - <https://ollama.com/library/mixtral>
