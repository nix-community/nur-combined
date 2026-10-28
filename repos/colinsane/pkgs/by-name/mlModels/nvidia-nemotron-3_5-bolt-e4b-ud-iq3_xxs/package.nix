# <https://huggingface.co/unsloth/NVIDIA-Nemotron-3.5-Bolt-E4B-GGUF>
{ fetchFromHuggingFaceSane }:
let
  owner = "unsloth";
  repo = "NVIDIA-Nemotron-3.5-Bolt-E4B-GGUF";
  rev = "8953699ee63fb48791c71a034eb2b6be407f8510";
  draftModel = fetchFromHuggingFaceSane {
    inherit owner repo rev;
    path = "dflash-NVIDIA-Nemotron-3.5-Bolt-E4B-Q8_0.gguf";
    hash = "sha256-nJRptHVst3qTL8LBM43Shq/WWdtpo8842uU0ce2yAiU=";
  };
in
fetchFromHuggingFaceSane {
  inherit owner repo rev;
  path = "NVIDIA-Nemotron-3.5-Bolt-E4B-UD-IQ3_XXS.gguf";
  hash = "sha256-VUCGo22c3XZizUVmhMIcTY1gD7c/DVpjWSxZ6HYHtSk=";
  passthru = {
    inherit draftModel;
    preset = {
      spec-type = "draft-dflash";
      spec-draft-model = "${draftModel}";
      spec-draft-n-max = 7;
      spec-draft-ngl = 999;
    };
  };
}
