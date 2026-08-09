{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "jorge";
  version = "0.10.1-unstable-2026-08-09";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "facundoolano";
    repo = "jorge";
    rev = "ce46857630d9232ab360fc104e3e87f80715d137";
    hash = "sha256-YtThvdRH/IBXwikCuVL8V90myT8gOIZl3cC/NWhiSuQ=";
  };

  vendorHash = "sha256-8i9bNQacuAk8VJkDRCcIBfaOKHjPpve5wJRMxpbOs2c=";

  ldflags = [ "-s" ];

  meta = {
    description = "Personal site generator with org-mode support";
    homepage = "https://github.com/facundoolano/jorge";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "jorge";
  };
})
