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
    sha256 = "1ssc8ca3dk76z9qkcvnv7dga72ffhqn7jac1j4x3x8im292givip";
  };

  meta = {
    description = "Inofficial Netflix plugin for Kodi";
  };

  requiredPythonModules = [ kodiPlugins.kodi.pythonPackages.pycryptodomex ];
  propagatedBuildInputs = [ kodiPlugins.kodi.pythonPackages.pycryptodomex ];
})
