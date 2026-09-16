{
  lib,
  libarchive,
  cadical,
  fetchFromGitHub,
}:
{
  pname = "gbdc";
  version = "0.4.2+multi-opt";

  src = fetchFromGitHub {
    owner = "chrjabs";
    repo = "gbdc";
    rev = "f3c12c3743e3a007ec98c7820fad31c8aa286c0b";
    hash = "sha256-6/7nK6hqUVsXbiK0YYpVJgI9i3aQ1q653gms3l3MM5A=";
  };

  patches = [ ./cmake-system-cadical.patch ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.4.2"' 'version = "0.4.2+multi-opt"'
  '';

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
