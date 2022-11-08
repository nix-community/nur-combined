{
  fetchFromGitHub,
  lib, # enable to use lib.fakeHash

  proj,
  python3Packages
}:

proj.overrideAttrs (oldAttrs: rec {
  version = "9.1.0";

  src = fetchFromGitHub {
    owner = "OSGeo";
    repo = "PROJ";
    rev = "${version}";
    sha256 = "sha256-Upsp72RorV+5PFPHOK3zCJgVTRZ6fSVVFRope8Bp8/M="; # lib.fakeHash;
  };

  meta.maintainers = [ "imincik" ];
})
