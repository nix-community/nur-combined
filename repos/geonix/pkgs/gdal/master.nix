{ fetchFromGitHub, gdal }:

let
  srcRevision = import ./master-rev.nix;
in
{
  master = gdal.overrideAttrs (final: prev: {
    pname = "gdal-master";
    version = "git-${srcRevision.rev}";

    src = fetchFromGitHub {
      owner = "OSGeo";
      repo = "gdal";
      rev = srcRevision.rev;
      hash = srcRevision.hash;
    };

    patches = [ ];

    disabledTests = prev.disabledTests ++ [
      # failing with master
      # https://github.com/OSGeo/gdal/pull/10806#issuecomment-2362054085
      "test_ogr_gmlas_billion_laugh"
    ];
  });
}
