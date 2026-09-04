# try, e.g.:
# - `nix-build -A pkgsCross.aarch64-multiplatform.vanilla-mobile-nixos.pkgs.linuxKernels.linux_sdm845`
{
  fetchFromGitHub,
  flake-inputs,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-08-31";
  src = fetchFromGitHub {
    owner = "vanilla-mobile-nixos";
    repo = "vanilla-mobile-nixos";
    rev = "54b02e14e5652c01f7df44e97069d07027b19f01";
    hash = "sha256-cxG3XYYgfV4+B6p41MUP2dcb3xBWqe16mfQiwKljZnQ=";
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
