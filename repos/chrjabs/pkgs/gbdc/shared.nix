{
  lib,
  libarchive,
  cadical,
  fetchFromGitHub,
}:
{
  pname = "gbdc";
  version = "0.4.0+multi-opt";

  src = fetchFromGitHub {
    owner = "chrjabs";
    repo = "gbdc";
    rev = "44d636bf97c3ee7a4853a603c234c51a481c4ba4";
    hash = "sha256-2cRD7HSj5XXVNdDRHV9jSeJHchVzVMFCQ9s5SgZEviU=";
  };

  patches = [ ./cmake-system-cadical.patch ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.4.0"' 'version = "0.4.0+multi-opt"'
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
