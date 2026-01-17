{
  upstream,
  sources,
  source ? sources.opencode,
}:
upstream.opencode.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (source) version src;
    node_modules = prevAttrs.node_modules.overrideAttrs (
      subFinalAttrs: subPrevAttrs: {
        inherit (finalAttrs) version src;

        # nix-update auto -s node_modules
        outputHash = "sha256-1mxHtlq18f2dIkOkdxdCPlX6M9I3bd1DA8JCB4blqZE=";
      }
    );
    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
