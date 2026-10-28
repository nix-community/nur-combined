{
  lib,
  fetchFromRadicle,
  rustPlatform,
  rustc,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rad-plan";
  version = "0-unstable-2026-08-20";

  src = fetchFromRadicle {
    seed = "iris.radicle.network";
    repo = "z4L8L9ctRYn2bcPuUT4GRz7sggG1v"; # radicle-plan-cob
    rev = "2cd8eb104666ea4921ec3b1345db7e16b5579213";
    hash = "sha256-Cwuri24AR4SsJAZ8DyrakGKrnRmdZSe8FMMTc0brMHw=";
  };

  cargoHash = "sha256-scxHbfLAbmXitE4IwcJPkgfAr5lHOzRyjiRP4gF7DEk=";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Collaborative Object for Claude Code Plans";
    homepage = "https://radicle.network/nodes/${finalAttrs.src.seed}/rad%3A${finalAttrs.src.repo}";
    changelog = "${finalAttrs.meta.homepage}/tree/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.OR [
      lib.licenses.mit
      lib.licenses.asl20
    ];
    inherit (rustc.meta) platforms;
    mainProgram = "rad-plan";
    maintainers = [ lib.maintainers.skyesoss ];
    hydraPlatforms = [
      "x86_64-linux"
    ];
  };
})
