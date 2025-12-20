{
  sources,
  version,
  hash,
  pnpm_10,
  fetchPnpmDeps,
  splayer,
}:
splayer.overrideAttrs (
  final: _prev: {
    inherit (sources) pname src;
    inherit version;
    pnpmDeps = fetchPnpmDeps {
      inherit (final) pname version src;
      inherit hash;
      pnpm = pnpm_10;
      fetcherVersion = 2;
    };
  }
)
