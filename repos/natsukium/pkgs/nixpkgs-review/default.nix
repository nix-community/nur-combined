{
  source,
  nixpkgs-review,
  python3Packages,
}:
nixpkgs-review.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "${prevAttrs.version}-fork-${source.date}";
    name = "${prevAttrs.pname}-${finalAttrs.version}";
    inherit (source) src;
    propagatedBuildInputs =
      prevAttrs.propagatedBuildInputs
      ++ (with python3Packages; [
        backoff
        humanize
      ]);

    meta = prevAttrs.meta // {
      description = "Patched version of nixpkgs-review with additional features";
      homepage = "https://github.com/natsukium/nixpkgs-review";
    };
  }
)
