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
      hash = "sha256-k/05ccqV72kC9E9MX+os8R0wmgIhnDYIwRNmIbedL1I=";
    };

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
