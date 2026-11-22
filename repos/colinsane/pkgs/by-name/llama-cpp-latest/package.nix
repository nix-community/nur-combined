{
  llama-cpp,
  nix-update-script,
  # vulkanSupport ? false,  #< you may want to `override` this to `true`
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
  llama-cpp'.overrideAttrs (finalAttrs: prevAttrs: {
    version = "12618";
    src = prevAttrs.src.override {
      tag = "b${finalAttrs.version}";
      hash = "sha256-Iw0WeqEJjxrC2neFe3rCf9Jyx3OWvxrLAvTRyJGyBO4=";
    };
    npmRoot = "ui/lib/ui";
    makeCacheWritable = true;
    npmDepsHash = "sha256-ID0MtY51T6Hwr1h+4Z/aIJapqIY2rbYtuLZXiJ+QKjw=";

    passthru = (prevAttrs.passthru or {}) // {
      updateScript = nix-update-script { };
    };
  })
