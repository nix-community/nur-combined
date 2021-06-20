{ batexpe }:

batexpe.overrideAttrs (attrs: rec {
  version = "master";
  src = builtins.fetchurl "https://framagit.org/api/v4/projects/batsim%2Fbatexpe/repository/archive.tar.gz?sha=master";
})
