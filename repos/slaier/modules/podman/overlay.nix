final: prev: {
  podman-compose = prev.podman-compose.overrideAttrs (old:
    let
      version = "1.0.6";
    in
    assert (builtins.compareVersions old.version "1.0.6") == -1;
    {
      inherit version;
      src = prev.fetchFromGitHub {
        owner = "containers";
        repo = "podman-compose";
        rev = "v${version}";
        sha256 = "sha256-TsNM5xORqwWge+UCijKptwbAcIz1uZFN9BuIOl28vIU=";
      };
    });
}
