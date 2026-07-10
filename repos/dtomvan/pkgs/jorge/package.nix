{
  lib,
  buildGoModule,
  fetchFromGitHub,
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
