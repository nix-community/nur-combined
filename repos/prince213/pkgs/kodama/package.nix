{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kodama";
  version = "1.0.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "kokic";
    repo = "kodama";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vATf+cgZWNIKA9Bai/wc2j2ntDmNalWdi91u4UTsiZE=";
  };

  cargoHash = "sha256-YGkI6+/7gyywBPMBjwT9Lz99Gia2ETKpRyvebe0zzYQ=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Typst-friendly static Zettelkästen site generator";
    homepage = "https://github.com/kokic/kodama";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
