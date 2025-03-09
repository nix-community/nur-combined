{
  fetchFromGitHub,
  nheko,
  nix-update-script,
}:

nheko.overrideAttrs (prevAttrs: {
  version = "0.12.0-unstable-2025-03-07";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "nheko";
    rev = "3cd45b65a1b77e05929ca8318c9c6cd3f4be9e96";
    hash = "sha256-hKW4xTr1pfG6nB9iTZXWmKly4hdXTm54K8O53v5+ya8=";
  };

  passthru = (prevAttrs.passthru or { }) // {
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
      ];
    };
  };
})
