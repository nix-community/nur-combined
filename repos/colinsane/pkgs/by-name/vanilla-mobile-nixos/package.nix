# try, e.g.:
# - `nix-build -A pkgsCross.aarch64-multiplatform.vanilla-mobile-nixos.pkgs.linuxKernels.linux_sdm845`
{
  fetchFromGitHub,
  flake-inputs,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-09-07";
  src = fetchFromGitHub {
    owner = "vanilla-mobile-nixos";
    repo = "vanilla-mobile-nixos";
    rev = "60bd643b2042c5fe2da529aa724363a5ed4e99d0";
    hash = "sha256-hOQkIpvEsQ7wbDqC+zu54zy7hB6LXIwKVvL+HPaLQTA=";
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
