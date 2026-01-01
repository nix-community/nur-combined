self: prev: {
  transmission_4 = prev.transmission_4.overrideAttrs (_: {
    version = "4.0.5";

    src = self.fetchFromGitHub {
      owner = "transmission";
      repo = "transmission";
      rev = "4.0.5";
      hash = "sha256-gd1LGAhMuSyC/19wxkoE2mqVozjGPfupIPGojKY0Hn4=";
      fetchSubmodules = true;
    };
  });
}
