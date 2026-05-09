{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule {
  __structuredAttrs = true;

  pname = "go-check";
  version = "0-unstable-2025-06-14";
  src = fetchFromGitHub {
    owner = "Dreamacro";
    repo = "go-check";
    rev = "02e5362ac59c76133789e921c4207cc4a51fba26";
    hash = "sha256-6GjPcCJt84mG7llNdwniqhsNYbMZwxbEtP6akdFKwDc=";
  };

  vendorHash = "sha256-TavyCVdPmoAilFafzJUxfxJH+zHHSBGzWKX46PG451Y=";

  subPackages = [ "." ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Check for outdated go module";
    homepage = "https://github.com/Dreamacro/go-check";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xyenon ];
  };
}
