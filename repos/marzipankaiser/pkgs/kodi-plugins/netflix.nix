{ pkgs ? import <nixpkgs> {},
  ...
}:
with pkgs;
kodiPlugins.kodi.pythonPackages.toPythonModule (kodiPlugins.mkKodiPlugin rec {
  plugin = "netflix";
  namespace = "plugin.video.netflix";
  version = "v1.11.0";

  src = fetchFromGitHub {
    owner = "CastagnaIT";
    repo = "plugin.video.netflix";
    rev = "${version}";
    sha256 = "0wjjdbfjfarfgigr6cb8p7lmrikaz782rfaw7yid9qqwx4rcyv7a";
  };

  meta = {
    description = "Inofficial Netflix plugin for Kodi";
  };

  requiredPythonModules = [ kodiPlugins.kodi.pythonPackages.pycryptodomex ];
  propagatedBuildInputs = [ kodiPlugins.kodi.pythonPackages.pycryptodomex ];
})
