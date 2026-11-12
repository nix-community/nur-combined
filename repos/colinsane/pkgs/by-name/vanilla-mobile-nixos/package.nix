# try, e.g.:
# - `nix-build -A pkgsCross.aarch64-multiplatform.vanilla-mobile-nixos.pkgs.linuxKernels.linux_sdm845`
{
  fetchFromGitHub,
  flake-inputs,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-11-04";
  src = fetchFromGitHub {
    owner = "vanilla-mobile-nixos";
    repo = "vanilla-mobile-nixos";
    rev = "a7ff58edde58fceeeecb6c658efb4e1ebd700c6b";
    hash = "sha256-bfRixzU5b1D33w04Wada6HbYShW3S2h+LvC3AE7WSVY=";
  };
  flake = flake-inputs.import-flake {
    inherit src;
    # overrides.nixpkgs = ??
  };

  # confusingly, `pkgs/default.nix` takes `pkgs: self:` -- i.e. the *reverse* order of a typical overlay.
  pkgsOverlay = self: super: import "${src}/pkgs" super self;
  pkgsFinal = pkgs.extend pkgsOverlay;
in src.overrideAttrs (base: {
  # attributes required by update scripts.
  pname = "vanilla-mobile-nixos";
  src = src;
  version = version;

  passthru = base.passthru // {
    inherit flake pkgsOverlay;
    pkgs = pkgsOverlay pkgsFinal pkgs;
    updateScript = nix-update-script {
      extraArgs = [ "--version" "branch" ];
    };
  };
})
