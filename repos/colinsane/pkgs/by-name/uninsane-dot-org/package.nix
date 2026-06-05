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
    rev = "adc25aaa1a98dd266a7d53af9f242bf219b54bfa";
    hash = "sha256-WXs5Dx59zeFCOeOjnbTS73s4RqR3+6fRsuE1xlN5y84=";
  };
  pkg = callPackage "${src}/default.nix" { };
in
  pkg.overrideAttrs (base: {
    inherit src;
    pname = "uninsane-dot-org";
    version = "0-unstable-2026-06-01";
    passthru = (base.passthru or {}) // {
      updateScript = nix-update-script {
        extraArgs = [ "--version" "branch" ];
      };
    };
  })
