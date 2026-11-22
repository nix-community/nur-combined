{
  callPackage,
  fetchPnpmDeps,
  go_1_27,
  lib,
  pnpm_11,
  pocket-id,
  source ? callPackage ./source.nix { },
}:

let
  basePocketId =
    if (lib.functionArgs pocket-id.override) ? pnpm_10 then
      pocket-id.override { pnpm_10 = pnpm_11; }
    else
      pocket-id;
  goMinor = lib.versions.majorMinor go_1_27.version;
in
basePocketId.overrideAttrs (
  finalAttrs: previousAttrs: {
    inherit (source) version src vendorHash;

    # Upstream pocket-id bumps Go patch versions in backend/go.mod ahead of nixpkgs.
    postPatch = (previousAttrs.postPatch or "") + ''
      sed -i -E 's/^go ${lib.escapeRegex goMinor}\.[0-9]+$/go ${go_1_27.version}/' go.mod
    '';

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
