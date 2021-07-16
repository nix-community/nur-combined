{ simgrid }:

simgrid.overrideAttrs (attrs: rec {
  version = "master";
  src = fetchTarball "https://github.com/simgrid/simgrid/tarball/master";
  patches = [];
})
