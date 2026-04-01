{
  gleam,
  callPackage,
}:

gleam.overrideAttrs (
  finalAttrs: prevAttrs: {
    passthru = prevAttrs.passthru // {
      fetchDeps = callPackage ./fetchDeps.nix { inherit gleam; };
      erlangHook = callPackage ./erlangHook.nix { inherit gleam; };
      javascriptHook = callPackage ./javascriptHook.nix { inherit gleam; };
      build = callPackage ./build.nix { inherit gleam; };
    };
  }
)
