{
  nixpkgs,
  sources,
  fetchPnpmDeps,

  source ? sources.nezha-theme-user,
}:
nixpkgs.nezha-theme-user.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (source) pname version src;

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 4;
      # nix-update auto
      hash = "sha256-eM5EHuSQLrmo/bduvY9Z1j7lHkQz7wCPrHWkU759VXY=";
    };

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
