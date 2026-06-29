{
  nixpkgs,
  sources,

  source ? sources.nezha,
  withThemes ? [ ],
}:
(nixpkgs.nezha.override { inherit withThemes; }).overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (source) version src;

    # nix-update auto
    vendorHash = "sha256-U2rZVluYM+XcI8e9TBXAlb9sKz4IL+FMEj1CTDcH6qM=";

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
