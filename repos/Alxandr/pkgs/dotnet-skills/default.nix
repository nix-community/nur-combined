{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-08-26";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "3cd1337923f35817cccd6562abe53f81c63e594f";
    sha256 = "sha256-a/CMqhNInNjCYeZJhbfGk+OM/KILNdHNgwnm7DmtrnQ=";
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
