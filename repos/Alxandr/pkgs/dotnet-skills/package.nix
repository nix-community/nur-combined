{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-10-16";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "10d85e25fb42d5f65c568d5e979a005ee69eecb3";
    sha256 = "sha256-ynj5Z+w77tg5XYQKn9OaIyys7ZPq6GRwHxJFtQtEvQU=";
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
