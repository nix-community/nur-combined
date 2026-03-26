let
  /**
    Generate my package set given a Nixpkgs instance
  */
  mkPkgs =
    pkgs: builtins.removeAttrs (
      import ./.. { inherit pkgs; }
    ) [ "overlays" ];

  /**
    Extend the Nixpkgs Python package set
  */
  python =
    final: prev:
    {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (mkPkgs prev).pythonOverlay
      ];
    };

  /**
    Use SnapPy and Regina from inside Sage + KnotJob
  */
  math =
    final: prev:
    {
      inherit (mkPkgs prev)
        knotjob
        sage
        snappy-topology
        regina-normal
        ;
    }
    // python final prev;

  /**
    Mostly for personal use, YMMV
  */
  all =
    final: prev: (mkPkgs prev) // python final prev;

  default = all;
in

{
  inherit
    default
    math
    python
    all
    ;
}
