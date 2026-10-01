{
  sing-box-dashboard,
}:

sing-box-dashboard.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "0-unstable-2026-09-28";

  src = previousAttrs.src.override {
    rev = "f231354bc786dfcffcf09f6ec771bc5683050194";
    hash = "sha256-+ZjEH3GecYEMmUPawWa6KzUkaHp9utLMCDLEphs1Hmk=";
  };

  pnpmDeps = previousAttrs.pnpmDeps.override {
    hash = "sha256-MCld/J2LBtAz2bS00ICjCQN/QPXlLDKwzEGtFwlEl8c=";
  };

  meta = previousAttrs.meta // {
    branch = "dev";
  };
})
