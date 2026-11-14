{
  callPackage,
  fetchPnpmDeps,
  pnpm_11,
  pocket-id,
  source ? callPackage ./source.nix { },
}:

(pocket-id.override { pnpm_10 = pnpm_11; }).overrideAttrs (
  finalAttrs: previousAttrs: {
    inherit (source) version src vendorHash;
    frontend = previousAttrs.frontend.overrideAttrs {
      inherit (finalAttrs) src version;
      pnpmDeps = fetchPnpmDeps {
        inherit (finalAttrs) pname version src;
        pnpm = pnpm_11;
        fetcherVersion = 5;
        hash = source.pnpmDepsHash;
      };
    };
  }
)
