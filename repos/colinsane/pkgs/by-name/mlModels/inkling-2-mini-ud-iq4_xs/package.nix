# Thinking Machines' Inkling 2 Mini model, quantized by Unsloth.
# <https://huggingface.co/unsloth/Inkling-2-Mini-GGUF>
# <https://unsloth.ai/docs/models/inkling-2-mini>
#
# N.B.: mainline llama-cpp support is lacking on release date;
# docs suggest to take from `Mainline_Support/` directory and omit MTP
# - <https://unsloth.ai/docs/models/inkling-2-mini#run-inkling-2-mini-in-llama-cpp>
# - OR: build unsloth's llama-cpp fork
{ fetchFromHuggingFaceSane }:
let
  owner = "unsloth";
  repo = "Inkling-2-Mini-GGUF";
  rev = "ae9327c5fbc7333116ba32eee78bb5d2bbefae4f";
  # draftModel = fetchFromHuggingFaceSane {
  #   inherit owner repo rev;
  #   path = "dspark-Inkling-2-Mini-Q8_0.gguf";
  #   hash = "sha256-kcMkIW1h7zBOTp4euLl3PMOI6JvI2KCdnkV3LplmLpM=";
  # };
in
fetchFromHuggingFaceSane {
  inherit owner repo rev;
  path = "Mainline_Support/Inkling-2-Mini-UD-IQ4_XS.gguf_file";
  name = "Inkling-2-Mini-UD-IQ4_XS.gguf";
  hash = "sha256-AMWCYeYpwKA+7NPZYS31FPZ9p/m+bxBmP30d1PmI6xc=";
  # passthru = {
  #   inherit draftModel;
  #   preset = {
  #     # <https://huggingface.co/unsloth/Inkling-2-Mini-GGUF/blob/main/dspark/README.md>
  #     # requires: <https://github.com/ggml-org/llama.cpp/pull/32218>
  #     spec-type = "draft-dspark";
  #     spec-draft-model = "${draftModel}";
  #     spec-draft-n-max = 3;
  #     # spec-draft-ngl = 999;
  #   };
  # };
}
