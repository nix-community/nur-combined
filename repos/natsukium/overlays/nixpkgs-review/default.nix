final: prev: {
  nixpkgs-review =
    let
      source =
        (import ../../_sources/generated.nix {
          inherit (prev)
            fetchgit
            fetchurl
            fetchFromGitHub
            dockerTools
            ;
        }).nixpkgs-review;
    in
    prev.nixpkgs-review.overrideAttrs (
      finalAttrs: prevAttrs: {
        version = "${prevAttrs.version}-fork-${source.date}";
        name = "${prevAttrs.pname}-${finalAttrs.version}";
        inherit (source) src;
        propagatedBuildInputs =
          prevAttrs.propagatedBuildInputs
          ++ (with prev.python3Packages; [
            backoff
            humanize
          ]);

        meta = prevAttrs.meta // {
          description = "Patched version of nixpkgs-review with additional features";
          homepage = "https://github.com/natsukium/nixpkgs-review";
        };
      }
    );
}
