# This file was generated by nvfetcher, please do not modify it manually.
{
  fetchgit,
  fetchurl,
  fetchFromGitHub,
  dockerTools,
}: {
  guitarix-vst-bin = {
    pname = "guitarix-vst-bin";
    version = "v0.4";
    src = fetchurl {
      url = "https://github.com/brummer10/guitarix.vst/releases/download/v0.4/Guitarix.vst3.zip";
      sha256 = "sha256-hE8cDzYdLdS+++42QCKuwhfgbOk/dRLXwZP1jW0VbQ8=";
    };
  };
}
