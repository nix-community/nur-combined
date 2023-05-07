final: prev: {
  smartdns = prev.smartdns.overrideAttrs (old:
    let
      version = "41";
    in
    assert (builtins.compareVersions old.version "39") == -1;
    {
      inherit version;
      src = prev.fetchFromGitHub {
        owner = "pymumu";
        repo = old.pname;
        rev = "Release${version}";
        sha256 = "sha256-FVHOjW5SEShxTPPd4IuEfPV6vvqr0RepV976eJmxqwM=";
      };
    });
}
