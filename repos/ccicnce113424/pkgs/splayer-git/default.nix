{
  sources,
  version,
  hash,
  splayer,
}:
splayer.overrideAttrs (
  final: _prev: {
    inherit (sources) pname src;
    inherit version;
    pnpmDeps = final.pnpm.fetchDeps {
      inherit (final) pname version src;
      inherit hash;
      fetcherVersion = 2;
    };
  }
)
