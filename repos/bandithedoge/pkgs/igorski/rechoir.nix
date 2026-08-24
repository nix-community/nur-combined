{ fetchFromGitHub, igorski }:
igorski.mkVst3 (finalAttrs: {
  pname = "rechoir";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "igorski";
    repo = "rechoir";
    rev = finalAttrs.version;
    hash = "sha256-khVKTGlhPuuBb51A/njcnGKNVMixDPUUsRIoMKGmyY0=";
  };

  meta = {
    description = "VST delay plugin where the repeats are pitch shifted in time to harmonize with the input signal";
    homepage = "https://www.igorski.nl/download/rechoir";
  };
})
