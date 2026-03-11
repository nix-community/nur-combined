{
  gleam,
  callPackage,
}:

gleam.overrideAttrs (
  finalAttrs: prevAttrs: {
    passthru = prevAttrs.passthru // {
      fetchDeps = callPackage ./fetchDeps.nix { };
      erlangHook = callPackage ./erlangHook.nix { };
      javascriptHook = callPackage ./javascriptHook.nix { };
      build = callPackage ./build.nix { };
    };
  }
)
