{ }:
_: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (py-final: _: {
      uv-build = py-final.callPackage ../packages/uv-build { };
    })
  ];
}
