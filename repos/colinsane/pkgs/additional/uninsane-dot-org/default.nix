{
  callPackage,
  fetchFromGitea,
  nix-update-script,
}:
let
  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "uninsane";
    rev = "40e6d9a79190d946b70bb708c3397d4e34ff3c4a";
    hash = "sha256-3sZE3fdKmc75ORbn8dtpkLz95nYY6dWMSVYFPGcYAmM=";
  };
  pkg = callPackage "${src}/default.nix" { };
in
  pkg.overrideAttrs (base: {
    inherit src;
    pname = "uninsane-dot-org";
    version = "0-unstable-2024-08-29";
    passthru = (base.passthru or {}) // {
      updateScript = nix-update-script {
        extraArgs = [ "--version" "branch" ];
      };
    };
  })
