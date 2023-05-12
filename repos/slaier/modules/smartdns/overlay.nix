final: prev: {
  smartdns = prev.smartdns.overrideAttrs (old:
    let
      version = "42";
    in
    assert (builtins.compareVersions old.version "39") == -1;
    {
      inherit version;
      src = prev.fetchFromGitHub {
        owner = "pymumu";
        repo = old.pname;
        rev = "Release${version}";
        sha256 = "sha256-mKJZxBFRv2vt7pIp6rO9cJaeuQQopIXmz+bFd2iBQJ4=";
      };
    });
}
