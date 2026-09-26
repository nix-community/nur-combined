{ fetchFromHuggingFaceSane }: fetchFromHuggingFaceSane {
  owner = "unsloth";
  repo = "Qwen3.5-2B-MTP-GGUF";
  path = "Qwen3.5-2B-UD-Q4_K_XL.gguf";
  rev = "e05864f8066d874d5f85aaff007ae57a2a7d1efe";
  hash = "sha256-HRMy0zmsyBZOE2oE/Yvxnugk+6Js6ZPIuAms3LkfNn0=";
  passthru = {
    preset = {
      spec-type = "draft-mtp";
      spec-draft-n-max = 4;
    };
  };
}
