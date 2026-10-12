{
  sing-box-dashboard,
}:

sing-box-dashboard.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "0-unstable-2026-10-11";

  src = previousAttrs.src.override {
    rev = "3e4bf08e5bf5b9417cf9c36e5a2d5abcb21bdd34";
    hash = "sha256-4pW32PWuN0pPAJ/zj07Y3mtvXZB9c/HuRGvEod7m40g=";
  };

  pnpmDeps = previousAttrs.pnpmDeps.override {
    hash = "sha256-MCld/J2LBtAz2bS00ICjCQN/QPXlLDKwzEGtFwlEl8c=";
  };

  meta = previousAttrs.meta // {
    branch = "dev";
  };
})
