{ pkgs ? import <nixpkgs> {},
  ...
}:
with pkgs;
kodiPlugins.mkKodiPlugin rec {
  plugin = "netflix";
  namespace = "plugin.video.netflix";
  version = "v1.10.0";

  src = fetchFromGitHub {
    owner = "CastagnaIT";
    repo = "plugin.video.netflix";
    rev = "${version}";
    sha256 = "1a8jrv1wp4jjl5sgv39n00crr8i34j1xvamaza1mabl0001mpcxc";
  };

  meta = {
    description = "Inofficial Netflix plugin for Kodi";
  };

  extraBuildInputs = [ pythonPackages.pycryptodomex ];
}
