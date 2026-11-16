{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-11-12";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "2877c712edc20643b72f64e2983b168e6661d607";
    sha256 = "sha256-CctE7eJNAGKET2VGJwHKczCeLeiUQyMPgm+AkE6DoeI=";
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
