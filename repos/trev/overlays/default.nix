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
      pkgs = import ../packages {
        system = prev.stdenv.hostPlatform.system;
        pkgs = prev;
      };
    in
    prev // pkgs;

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
