{ rsg }:

rsg.overrideAttrs (attrs: rec {
  version = "master";
  src = fetchTarball "https://github.com/simgrid/remote-simgrid/archive/${version}.tar.gz";
})
