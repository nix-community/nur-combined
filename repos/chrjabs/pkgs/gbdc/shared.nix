{
  lib,
  libarchive,
  cadical,
  fetchFromGitHub,
}:
{
  pname = "gbdc";
  version = "0.3.2-multi-opt";

  src = fetchFromGitHub {
    owner = "chrjabs";
    repo = "gbdc";
    rev = "1ada7b0472a58b25e27db0b287e9daf7617ece76";
    hash = "sha256-zU/tjh33s6dXn7Ycsrtqt5FmD5tmhlLjfJz970O+ttY=";
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
