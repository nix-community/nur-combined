{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "bird-lg-go";
  version = "1.4.8";
  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "bird-lg-go";
    tag = "v1.4.8";
    hash = "sha256-6nQmle8s5lG67DwnWri1cDZM99vKWHSMgBtOqC0b45U=";
  };
  vendorHash = "sha256-SmpCCvOP9HQh+Niqa3EhRGj1a7EXQgwRW2hTJgv+oIw=";

  modRoot = "frontend";

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/xddxdd/bird-lg-go/releases/tag/v${finalAttrs.version}";
    mainProgram = "frontend";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = lib.licenses.gpl3Only;
  };
})
