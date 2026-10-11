{
  sources,
  callPackage,
}:
let
  ntfsprogs-plus = callPackage ./package.nix { };
in
ntfsprogs-plus.overrideAttrs (prev: {
  inherit (sources) pname src;
  version = "${prev.version}-unstable-${sources.date}";
  passthru = (prev.passthru or { }) // {
    # Versions are tracked by nvfetcher (`just up`); the upstream gitUpdater does not apply.
    updateScript = null;
  };
})
