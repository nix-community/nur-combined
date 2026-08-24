{
  callPackage,
  fetchFromGitHub,
}:
(callPackage ./generic.nix {
  pname = "liboqs";
  version = "0-unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "open-quantum-safe";
    repo = "liboqs";
    rev = "8979276ad1eb008215aa78a3c56b3649f604bbb1";
    hash = "sha256-LMk1nfEy667wSsfM8LuikWiS2jgaOLEQC6KeKa4/r2g=";
  };
})
