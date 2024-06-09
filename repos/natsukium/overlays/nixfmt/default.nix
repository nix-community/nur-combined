final: prev: {
  nixfmt =
    let
      source =
        (import ../../_sources/generated.nix {
          inherit (prev)
            fetchgit
            fetchurl
            fetchFromGitHub
            dockerTools
            ;
        }).nixfmt;
    in
    prev.nixfmt.overrideAttrs (
      finalAttrs: prevAttrs: {
        version = "${prevAttrs.version}-rfc-${source.date}";
        name = "${prevAttrs.pname}-${finalAttrs.version}";
        inherit (source) src;

        buildInputs = [ prev.haskellPackages.pretty-simple ];

        meta = prevAttrs.meta // {
          description = "nixfmt adoped rfc101/166 style";
          homepage = "https://github.com/NixOS/nixfmt";
        };
      }
    );
}
