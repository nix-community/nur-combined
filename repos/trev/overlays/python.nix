{ }:
_: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: {
      modal = pyfinal.callPackage ../packages/modal { inherit (pyprev) synchronicity; };
      synchronicity = pyfinal.callPackage ../packages/synchronicity { };
      uv-build = pyfinal.callPackage ../packages/uv-build { inherit (pyprev) uv-build; };
    })
  ];
}
