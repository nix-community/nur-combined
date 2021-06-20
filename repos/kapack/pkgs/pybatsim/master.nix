{ pybatsim }:

pybatsim.overrideAttrs (attr: rec {
  version = "master";
  src = builtins.fetchurl "https://gitlab.inria.fr/api/v4/projects/batsim%2Fpybatsim/repository/archive.tar.gz?sha=master";
})
