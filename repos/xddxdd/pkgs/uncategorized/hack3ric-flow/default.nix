{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hack3ric-flow";
  version = "0.2.0-unstable-2026-08-30";
  src = fetchFromGitHub {
    owner = "hack3ric";
    repo = "flow";
    rev = "cd665d1ed1521f0e042ff8a5cf5e78ca992f090d";
    hash = "sha256-dsWCaOuZBrRNHuy/dOxDKQWTQ2PgaOaPLK4nRFM9h48=";
  };
  cargoHash = "sha256-FEc5j2tMRCfU2nRYC/0gbdk4BkF99R88dWdJzgDUoVU=";

  # Check requires netlink privileges
  doCheck = false;

  postFixup = ''
    rm -f $out/bin/DONTSHIPIT*
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    changelog = "https://github.com/hack3ric/flow/releases/tag/v${finalAttrs.version}";
    mainProgram = "flow";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "BGP flowspec executor";
    homepage = "https://github.com/hack3ric/flow";
    license = lib.licenses.bsd2;
  };
})
