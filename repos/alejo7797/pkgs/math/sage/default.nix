{
  __sage,
  pythonOverlay,
  pkgs,
  extraPythonPackages ? _: [ ],
  ...
}:

__sage.override {

  pkgs = pkgs.extend (
    _: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [ pythonOverlay ];
    }
  );

  extraPythonPackages =
    ps:
    [
      ps.regina
      ps.snappy
    ]
    ++ extraPythonPackages ps;

  requireSageTests = false;

}
