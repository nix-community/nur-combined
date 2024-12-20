# This file was generated by nvfetcher, please do not modify it manually.
{
  fetchgit,
  fetchurl,
  fetchFromGitHub,
  dockerTools,
}: {
  bassdrive = {
    pname = "bassdrive";
    version = "1.5.0";
    src = fetchurl {
      url = "https://www.tonelib.net/download/ToneLib-BassDrive-amd64.deb";
      sha256 = "sha256-FybUm1iPCzqO1VMSvRCCUDa2+WO4+4UQ8p0Ab3RjHLc=";
    };
  };
  easycomp = {
    pname = "easycomp";
    version = "2.0.1";
    src = fetchurl {
      url = "https://tonelib.net/download/ToneLib-EasyComp-amd64.deb";
      sha256 = "sha256-vGBruV8b3qJ1vNge/HtWPuYuLfYss3vSZfD6zXKH3Mo=";
    };
  };
  noisereducer = {
    pname = "noisereducer";
    version = "1.5.0";
    src = fetchurl {
      url = "https://www.tonelib.net/download/ToneLib-NoiseReducer-amd64.deb";
      sha256 = "sha256-XMEJS/m9Ofg8fD63prBoAcCE8F0qNpsCvDMHI4EfbL0=";
    };
  };
  tubewarmth = {
    pname = "tubewarmth";
    version = "2.0.1";
    src = fetchurl {
      url = "https://www.tonelib.net/download/ToneLib-TubeWarmth-amd64.deb";
      sha256 = "sha256-Rr+3foO57ZwofoE0aq6aQq2DWT6RZkcl9+1TOxdbYwU=";
    };
  };
  zoom = {
    pname = "zoom";
    version = "4.3.1";
    src = fetchurl {
      url = "https://www.tonelib.net/download/ToneLib-Zoom-amd64.deb";
      sha256 = "sha256-4q2vM0/q7o/FracnO2xxnr27opqfVQoN7fsqTD9Tr/c=";
    };
  };
}
