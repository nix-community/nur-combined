# ollama API isn't documented anywhere, and it has changed over time, but it's alluded to in a few places.
# 1. it's similar to an "OCI registry".
# 2. mention of endpoint: <https://github.com/ollama/ollama/issues/6470>
#   - https://registry.ollama.ai/v2/library/$model/manifests/$variant
#
# choosing a model, for coding:
# - <https://huggingface.co/spaces/mike-ravkine/can-ai-code-results>
# - <https://eqbench.com/>
# - <https://evalplus.github.io/leaderboard.html>
#
# choosing a model, for sensitive/illicit things ("Uncensored General Intelligence"):
# - <https://huggingface.co/spaces/DontPlanToEnd/UGI-Leaderboard>
# - <https://www.reddit.com/r/LocalLLaMA/comments/1hk0ldo/december_2024_uncensored_llm_test_results/>
# - search "abliterated" or "abliterate"
# - search "uncensored"
# - search "Eric Hartford" <https://erichartford.com/uncensored-models>
{
  lib,
  newScope,
}:
lib.recurseIntoAttrs (lib.makeScope newScope (self: with self; {
  mkOllamaModel = callPackage ./mkOllamaModel.nix { };

  athene-v2-72b-q2_K = callPackage ./athene-v2-72b-q2_K.nix { };
  aya-8b = callPackage ./aya-8b.nix { };
  codegeex4-9b = callPackage ./codegeex4-9b.nix { };
  codegemma-7b = callPackage ./codegemma-7b.nix { };
  codestral-22b = callPackage ./codestral-22b.nix { };
  deepseek-coder-7b = callPackage ./deepseek-coder-7b.nix { };
  deepseek-coder-v2-16b = callPackage ./deepseek-coder-v2-16b.nix { };
  deepseek-coder-v2-16b-lite-instruct-q5_1 = callPackage ./deepseek-coder-v2-16b-lite-instruct-q5_1.nix { };
  deepseek-r1-1_5b = callPackage ./deepseek-r1-1_5b.nix { };
  deepseek-r1-7b = callPackage ./deepseek-r1-7b.nix { };
  deepseek-r1-14b = callPackage ./deepseek-r1-14b.nix { };
  deepseek-r1-32b = callPackage ./deepseek-r1-32b.nix { };
  deepseek-r1-671b = callPackage ./deepseek-r1-671b.nix { };
  deepseek-r1-abliterated-14b = callPackage ./deepseek-r1-abliterated-14b.nix { };
  deepseek-r1-abliterated-32b = callPackage ./deepseek-r1-abliterated-32b.nix { };
  deepseek-r1-abliterated-70b = callPackage ./deepseek-r1-abliterated-70b.nix { };
  dolphin-mistral-7b = callPackage ./dolphin-mistral-7b.nix { };
  dolphin-mixtral-8x7b = callPackage ./dolphin-mixtral-8x7b.nix { };
  falcon2-11b = callPackage ./falcon2-11b.nix { };
  gemma2-9b = callPackage ./gemma2-9b.nix { };
  gemma2-27b = callPackage ./gemma2-27b.nix { };
  glm4-9b = callPackage ./glm4-9b.nix { };
  hermes3-8b = callPackage ./hermes3-8b.nix { };
  llama3-chatqa-8b = callPackage ./llama3-chatqa-8b.nix { };
  llama3_1-70b = callPackage ./llama3_1-70b.nix { };
  llama3_2-3b = callPackage ./llama3_2-3b.nix { };
  llama3_2-uncensored-3b = callPackage ./llama3_2-uncensored-3b.nix { };
  llama3_3-70b = callPackage ./llama3_3-70b.nix { };
  llama3_3-abliterated-70b = callPackage ./llama3_3-abliterated-70b.nix { };
  magicoder-7b = callPackage ./magicoder-7b.nix { };
  marco-o1-7b = callPackage ./marco-o1-7b.nix { };
  mistral-7b = callPackage ./mistral-7b.nix { };
  mistral-nemo-12b = callPackage ./mistral-nemo-12b.nix { };
  mistral-small-22b = callPackage ./mistral-small-22b.nix { };
  mistral-large-123b = callPackage ./mistral-large-123b.nix { };
  mixtral-8x7b = callPackage ./mixtral-8x7b.nix { };
  phi3_5-3b = callPackage ./phi3_5-3b.nix { };
  qwen2_5-7b = callPackage ./qwen2_5-7b.nix { };
  qwen2_5-14b = callPackage ./qwen2_5-14b.nix { };
  qwen2_5-32b = callPackage ./qwen2_5-32b.nix { };
  qwen2_5-32b-instruct-q2_K = callPackage ./qwen2_5-32b-instruct-q2_K.nix { };
  qwen2_5-abliterate-7b = callPackage ./qwen2_5-abliterate-7b.nix { };
  qwen2_5-abliterate-14b = callPackage ./qwen2_5-abliterate-14b.nix { };
  qwen2_5-abliterate-32b = callPackage ./qwen2_5-abliterate-32b.nix { };
  qwen2_5-coder-7b = callPackage ./qwen2_5-coder-7b.nix { };
  qwq-32b = callPackage ./qwq-32b.nix { };
  qwq-abliterated-32b = callPackage ./qwq-abliterated-32b.nix { };
  solar-pro-22b = callPackage ./solar-pro-22b.nix { };
  starcoder2-15b-instruct = callPackage ./starcoder2-15b-instruct.nix { };
  wizardlm2-7b = callPackage ./wizardlm2-7b.nix { };
  yi-coder-9b = callPackage ./yi-coder-9b.nix { };
}))
