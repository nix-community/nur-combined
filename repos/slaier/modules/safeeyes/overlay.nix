final: prev: {
  safeeyes = prev.safeeyes.overrideAttrs (old:
    let
      version = "2.1.5";
    in
    assert (builtins.compareVersions old.version "2.1.4") == -1;
    {
      inherit version;
      src = prev.python3.pkgs.fetchPypi {
        inherit (old) pname;
        inherit version;
        sha256 = "sha256-IjFDhkqtMitdcQORerRqwty3ZMP8jamPtb9oMHdre4I=";
      };
    });
}
