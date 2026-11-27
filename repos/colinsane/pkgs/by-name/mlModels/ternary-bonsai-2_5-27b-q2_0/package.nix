# <https://huggingface.co/prism-ml/Ternary-Bonsai-2.5-27B-GGUF>
# > the Q2_0 files run on upstream llama.cpp; PTQ1_0 is under upstream review
# PTQ1_0 PR: <https://github.com/ggml-org/llama.cpp/pull/29672>
{ fetchFromHuggingFaceSane }:
fetchFromHuggingFaceSane {
  owner = "prism-ml";
  repo = "Ternary-Bonsai-2.5-27B-gguf";
  path = "Ternary-Bonsai-2.5-27B-Q2_0-mtp.gguf";
  rev = "28a7093cc25bc151cc2b284c5570f12ce343fdcf";
  hash = "sha256-xfConeKf8WOj4062qf87ijJGidumETubsPebFaHN8QA=";
  passthru = {
    preset = {
      spec-type = "draft-mtp";
      # not measured; chosen imprecisely.
      # references: <https://huggingface.co/prism-ml/Ternary-Bonsai-2.5-27B-GGUF/blob/main/presets/llama.cpp>
      spec-draft-n-max = 4;
    };
  };
}
