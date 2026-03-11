{
  buf,
  callPackage,
}:

buf.overrideAttrs (
  finalAttrs: prevAttrs: {
    passthru = prevAttrs.passthru // {
      fetchDeps = callPackage ./fetchDeps.nix { };
      hook = callPackage ./hook.nix { };
    };
  }
)
