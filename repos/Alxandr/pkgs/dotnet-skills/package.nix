{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-09-17";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "8bbfe7a4d1c5c0cd42cd04e38031779c75f2dda3";
    sha256 = "sha256-kAPn5TitrmmXWwUibEaU70b7hZGWNW4T5zJZPLjURsY=";
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
