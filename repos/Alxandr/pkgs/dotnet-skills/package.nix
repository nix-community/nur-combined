{
  lib,
  nurLib,
  fetchFromGitHub,
  nix-update-script,
}:
nurLib.mkAgentPlugins (finalAttrs: {
  pname = finalAttrs.finalPackage.marketplace.name or "dotnet-skills";
  version = "unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "skills";
    rev = "a6bf43ab61967c30919334986515163ab24d7635";
    sha256 = "sha256-jbv6CrsIkhRahJ6bo2c/M/ji9g0LoRTqjiBQr/0J9hQ=";
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
