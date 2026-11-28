{
  llama-cpp,
  nix-update-script,
  # vulkanSupport ? false,  # you may want to `override` this to `true`
  ...
}@callArgs:
let
  llama-cpp' = llama-cpp.override (
    removeAttrs callArgs [
      # "lib"
      "llama-cpp"
      "nix-update-script"
    ]
  );
in
llama-cpp'.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "12632";
    src = prevAttrs.src.override {
      tag = "b${finalAttrs.version}";
      hash = "sha256-8OxpJVMO3Kq4h7yrm8YjOcXk9QhaZPZdzDA0scqyVv0=";
    };
    npmRoot = "ui/lib/ui";
    makeCacheWritable = true;
    npmDepsHash = "sha256-ID0MtY51T6Hwr1h+4Z/aIJapqIY2rbYtuLZXiJ+QKjw=";

    passthru = (prevAttrs.passthru or { }) // {
      updateScript = nix-update-script { };
    };
  }
)
