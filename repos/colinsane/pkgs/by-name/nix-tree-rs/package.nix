{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nix-tree-rs";
  version = "0-unstable-2025-07-26";

  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "nix-tree-rs";
    rev = "bcc6b3682b246988377e8c633ef45b484dcc19ff";
    hash = "sha256-xv+fVoCd5rogqCyH8s8Xh+S+A6Ts09WNyT8ZwxRy6Bg=";
  };

  cargoHash = "sha256-A5DwZU5WyrlYLilvAbhx9qirOlT71K2I0OAaN8vIKPE=";

  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version" "branch" ];
  };

  meta = {
    description = "A Rust port of nix-tree, providing an interactive visualization of Nix store dependencies";
    homepage = "https://github.com/lonerOrz/nix-tree-rs";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
