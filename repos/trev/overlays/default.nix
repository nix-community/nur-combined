{
  default =
    _: prev:
    let
      nur = import ../. {
        system = prev.stdenv.hostPlatform.system;
        pkgs = prev;
      };
    in
    {
      trev = nur;
    };

  packages =
    _: prev:
    let
      packages = import ../packages {
        system = prev.stdenv.hostPlatform.system;
        pkgs = prev;
      };
    in
    prev // packages;

  pythonPackages = _: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (py-final: _: {
        uv-build = py-final.callPackage ../packages/uv-build { };
      })
    ];
  };

  libs =
    _: prev:
    let
      libs = import ../libs {
        system = prev.stdenv.hostPlatform.system;
        pkgs = prev;
      };
    in
    {
      lib = prev.lib // libs;
    };

  images =
    _: prev:
    let
      images = import ../images {
        system = prev.stdenv.hostPlatform.system;
        pkgs = prev;
      };
    in
    {
      image = images;
    };
}
