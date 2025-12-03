{ lib, vaculib, ... }:
lib.pipe (vaculib.directoryGrabber { path = ./.; }) [
  builtins.attrValues
  (map import)
]
