{
  deno,
  callPackage,
}:

deno.overrideAttrs (
  finalAttrs: prevAttrs: {
    passthru = prevAttrs.passthru // {
      compile = callPackage ./compile.nix { };
    };
  }
)
