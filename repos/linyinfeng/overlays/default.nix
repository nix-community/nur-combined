{
  # TODO wait for https://github.com/c0fec0de/anytree/issues/270
  # TODO wait for https://github.com/NixOS/nixpkgs/issues/375763
  anytree-workaround =
    final: prev:
    let
      lib = prev.lib;
      version = lib.trivial.version;
    in
    lib.optionalAttrs ((lib.versions.majorMinor version) == "25.05") {
      python3Packages = prev.python3Packages.overrideScope (
        _finalPy: prevPy: {
          anytree = prevPy.anytree.overrideAttrs (old: {
            patches = old.patches ++ [ ./python-anytree-poetry-project-name-version.patch ];
          });
        }
      );
    };
}
