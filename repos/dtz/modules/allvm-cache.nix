{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.allvm;
in {
  options.allvm = {
    useDirectS3URL = mkOption {
      type = types.bool;
      default = false;
      description = "Use Direct S3 for ALLVM cache. Hydra builders should use this to avoid CloudFront's negative cache.";
    };
  };

  config = {
    nix.binaryCaches = [
      "https://cache.nixos.org/"
      (if cfg.useDirectS3URL then
        "https://s3.amazonaws.com/cache.allvm.org/"
      else
        "https://cache.allvm.org/"
      )
    ];

    nix.binaryCachePublicKeys = [
      "gravity.cs.illinois.edu-1:yymmNS/WMf0iTj2NnD0nrVV8cBOXM9ivAkEdO1Lro3U="
    ];
  };
}
