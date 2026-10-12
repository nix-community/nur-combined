{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-10-12";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "19bb55d785cd88ce47a1b43f9a21d0192c412dac";
    sha256 = "sha256-IDyeaZho5+uzuXWAnIQk5L8O7BM4EvGnzFfx3GjzLQ8=";
  };

  marketplace = ./marketplace.json;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch=main"
      "--version-regex"
      "^0-(.*)$"
    ];
  };

  meta = {
    description = ".NET Agent Skills";
    homepage = "https://github.com/dotnet/skills";
    license = lib.licenses.mit;
  };
})
