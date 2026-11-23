{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-11-20";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "c227688ed14de4467e3e45f95dc69a94e905e219";
    sha256 = "sha256-hhQZB15i73RlkC7XnjZyhYBZgHZDYy/QCjeFxNobVJc=";
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
