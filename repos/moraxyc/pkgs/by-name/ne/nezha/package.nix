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
    vendorHash = "sha256-rYzkaJqk5r31Uagn1FRFDeICUeK392o1fyP6IBk9zgk=";

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
