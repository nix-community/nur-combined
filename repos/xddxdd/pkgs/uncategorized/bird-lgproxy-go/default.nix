{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "bird-lgproxy-go";
  version = "1.4.8";
  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "bird-lg-go";
    tag = "v1.4.8";
    hash = "sha256-6nQmle8s5lG67DwnWri1cDZM99vKWHSMgBtOqC0b45U=";
  };
  vendorHash = "sha256-LRj5OvCu0e0iNW8nEUmbnKhhvaUXOVNIYGv0Lmai28g=";

  modRoot = "proxy";

  passthru.updateScript = nix-update-script { };
  meta = {
    mainProgram = "proxy";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = lib.licenses.gpl3Only;
  };
})
