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
        outputHash = "sha256-WZauk7tIq+zpzsnmRpCSBQV3DChVUtDxd8kf2di13Jk=";
      }
    );
    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
