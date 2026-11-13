{ ... }: {
  boot.kernelPatches = [
    {
      name = "cs35l41-resume-dsp";
      patch = ./cs35l41-resume-dsp.patch;
    }
  ];
}
