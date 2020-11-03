{ pkgs ? import <nixpkgs> {},
  ...
}:
with pkgs;
kodiPlugins.kodi.pythonPackages.toPythonModule (kodiPlugins.mkKodiPlugin rec {
  plugin = "netflix";
  namespace = "plugin.video.netflix";
  version = "v1.10.0";

  src = fetchFromGitHub {
    owner = "CastagnaIT";
    repo = "plugin.video.netflix";
    rev = "${version}";
    sha256 = "1b7pry6cmajg4swl01z5q1azajlsxsp881pq8mdk31kc48q37xzm";
  };

  meta = {
    description = "Inofficial Netflix plugin for Kodi";
  };

  requiredPythonModules = [ kodiPlugins.kodi.pythonPackages.pycryptodomex ];
  propagatedBuildInputs = [ kodiPlugins.kodi.pythonPackages.pycryptodomex ];
})
