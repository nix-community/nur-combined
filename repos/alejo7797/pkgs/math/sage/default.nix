{
  __sage,
  pythonOverlay,
  pkgs,
  extraPythonPackages ? _: [],
  ...
}:

__sage.override {

  pkgs = pkgs.extend (
    _: prev: {
      python3 = prev.python3.override { packageOverrides = pythonOverlay; };
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
