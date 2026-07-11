{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchpatch2,
}:

buildGoModule (finalAttrs: {
  pname = "jorge";
  version = "0.10.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "facundoolano";
    repo = "jorge";
    tag = finalAttrs.version;
    hash = "sha256-AP1KDEIW8nI97+OuFJIJv6bFsT8c5x5kRNGfcyIvQGg=";
  };

  patches = [
    (fetchpatch2 {
      url = "https://github.com/dtomvan/jorge/commit/f26d32cb5795e9354ee67fb712883e0e1cfdc647.patch";
      hash = "sha256-3zKKUuupTNWu16k+mzeAMRXQgd29nuNtsp98Flrb/E0=";
    })
  ];

  vendorHash = "sha256-8i9bNQacuAk8VJkDRCcIBfaOKHjPpve5wJRMxpbOs2c=";

  ldflags = [ "-s" ];

  meta = {
    description = "A personal site generator with org-mode support";
    homepage = "https://github.com/facundoolano/jorge";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "jorge";
  };
})
