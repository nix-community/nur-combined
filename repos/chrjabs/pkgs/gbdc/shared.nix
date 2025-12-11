{
  lib,
  libarchive,
  cadical,
  fetchFromGitHub,
}:
{
  pname = "gbdc";
  version = "0.3.3-multi-opt";

  src = fetchFromGitHub {
    owner = "chrjabs";
    repo = "gbdc";
    rev = "62fbff9a481f5ac12f95a3ca15c6e77c51e816ae";
    hash = "sha256-6vGaMQQqkKe95OYB91Nbt8d3ucDWD5wEdHUSZAl2RSs=";
  };

  patches = [ ./adjust-cmake-for-nix.patch ];

  buildInputs = [
    libarchive
    cadical
  ];

  meta = {
    description = "Instance Identification, Feature Extraction, and Problem Transformation";
    homepage = "https://github.com/Udopia/gbdc";
    license = lib.licenses.mit;
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
    platforms = lib.platforms.all;
  };
}
