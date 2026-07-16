{
  lib,
  linkFarm,
  mlModels,
}:
let
  models = {
    inherit (mlModels)
      # # gemma-4-e2b-it-bf16
      # gemma-4-e2b-it-q4_k_s
      # # gemma-4-e2b-it-q6_k
      # gemma-4-e2b-it-q8_0
      # gemma-4-e4b-it-q3_k_s
      # gemma-4-e4b-it-q4_k_m
      # gemma-4-e4b-it-q4_k_s
      # # gemma-4-e4b-it-q5_k_m
      # # gemma-4-e4b-it-q5_k_s
      # # gemma-4-e4b-it-q6_k
      # gemma-4-12b-it-iq4_nl
      # gemma-4-12b-it-iq4_xs
      # gemma-4-12b-it-q3_k_m
      # gemma-4-12b-it-q3_k_s
      # gemma-4-12b-it-q4_k_m
      # gemma-4-12b-it-q4_k_s
      # gemma-4-12b-it-ud-iq3_xxs
      # gemma-4-12b-it-ud-q3_k_xl
      # gemma-4-12b-it-ud-q4_k_xl
      # gemma-4-26b-a4b-it-mxfp4_moe
      # gemma-4-26b-a4b-it-ud-q4_k_m
      # gemma-4-31b-it-bf16
      # gemma-4-31b-it-q4_k_m
      # gemma-4-31b-it-q8_0
      # gemma-4-e4b-it-qat-ud-q4_k_xl
      # gemma-4-12b-it-qat-ud-q4_k_xl
      # gemma-4-26b-a4b-it-qat-ud-q4_k_xl
      # gemma-4-31b-it-qat-ud-q4_k_xl
      # glm-4_7-flash
      gpt-oss-20b
      # lfm2_5-230m-fable-5-q8_0
      lfm2_5-8b-a1b-ud-iq4_xs
      liquidai-lfm2-24b-a2b-iq4_xs
      # minimax-m2_5
      # nemotron-3-nano-4b
      # nemotron-3-nano-30b-a3b
      # omnicoder-9b
      ornith-1_0-35b-q4_k_m
      qwen-agentworld-35b-a3b-ud-iq2_m
      qwen-agentworld-35b-a3b-ud-iq3_s  # seems equally capable as iq4_nl
      # qwen-agentworld-35b-a3b-iq4_nl
      # qwen3_5-35b-a3b-q4_k_m
      # qwen3_5-9b-q4_k_m
      # qwen3_5-4b-claude-4_6-opus-reasoning-distilled-q3_k_s
      # qwen3_5-4b-claude-4_6-opus-reasoning-distilled-q3_k_m
      # qwen3_5-4b-claude-4_6-opus-reasoning-distilled-v2
      # qwen3_5-9b-claude-4_6-opus-reasoning-distilled-v2-q4_k_m
      # qwen3_5-9b-claude-4_6-opus-reasoning-distilled-q2_k
      # qwen3_5-9b-claude-4_6-opus-reasoning-distilled-q3_k_m
      # qwen3_5-27b-claude-4_6-opus-reasoning-distilled-v2
      qwen3_5-122b-a10b-ud-iq4_xs
      # qwen3_5-122b-a10b-ud-q4_k_xl
      qwen3_6-27b-mtp-q4_k_m
      # qwen3_6-35b-a3b-ud-q4_k_m
      qwen3_6-35b-a3b-mtp-ud-q4_k_m
      qwopus3_6-35b-a3b-coder-mtp-q4_k_m
      # qwythos-9b-claude-mythos-5-1m-q4_k_m
      qwythos-9b-v2-q4_k_m
      step3_7-flash-iq4_xs
    ;
  };
in
(linkFarm "llama-cpp-models" (lib.mapAttrs'
  (k: value: {
    inherit value;
    inherit (value) name;
  })
  models
)).overrideAttrs (prevAttrs: {
  passthru = (prevAttrs.passthru or {}) // {
    models = lib.mapAttrs (k: drv: drv.overrideAttrs (prevAttrs': {
      passthru = (prevAttrs'.passthru or {}) // {
        id = lib.removeSuffix ".gguf" drv.name;
      };
    })) models;
  };
})

