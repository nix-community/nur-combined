{
  uv-build,
  callPackage,
}:

uv-build.overrideAttrs (
  finalAttrs: prevAttrs: {
    passthru = prevAttrs.passthru // {
      latest = callPackage ./latest.nix { };
    };
  }
)
