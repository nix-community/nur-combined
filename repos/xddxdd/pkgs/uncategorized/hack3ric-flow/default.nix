{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hack3ric-flow";
  version = "0.2.0-unstable-2026-04-05";
  src = fetchFromGitHub {
    owner = "hack3ric";
    repo = "flow";
    rev = "4a406621a71e806541c833181b9c2f5cf6fc759f";
    hash = "sha256-4n7EU+F98dk3gHKEEof8cNa8WkOwxR17b4vPyHJ1rao=";
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
