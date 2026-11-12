{
  lib,
  maintainers,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  git,
  nh,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "narf";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "farbzen";
    repo = "narf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RuTANVptaDnYGiXz3UZZ/bFV2glRSFvkhw5AuAEVGc0=";
  };

  cargoHash = "sha256-nkwnnpHvPMcBc1K+/EpningBDssGz/ojqCJ8S9yiZgo=";

  nativeBuildInputs = [makeWrapper];

  postInstall = ''
    for program in $out/bin/narf $out/bin/narf-tui; do
      wrapProgram "$program" --prefix PATH : ${lib.makeBinPath [git nh]}
    done
  '';

  meta = {
    description = "NixOS Advanced Rebuild Flake - Rebuilding nix flakes and creating commits";
    homepage = "https://github.com/farbzen/narf";
    changelog = "https://github.com/farbzen/narf/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "narf";
    maintainers = [maintainers.farbzen];
  };
})
