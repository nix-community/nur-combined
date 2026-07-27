{
  sources,

  lib,

  buildNpmPackage,
  importNpmLock,
  pi-coding-agent,
}:
buildNpmPackage {
  inherit (sources.pi-acp) pname src;
  version = lib.removePrefix "v" sources.pi-acp.version;

  npmDeps = importNpmLock {
    package = lib.importJSON sources.pi-acp.extract."package.json";
    packageLock = lib.importJSON sources.pi-acp.extract."package-lock.json";
  };

  inherit (importNpmLock) npmConfigHook;

  meta = {
    description = "ACP adapter for pi coding agent";
    homepage = "https://github.com/svkozak/pi-acp";
    license = lib.licenses.mit;
    inherit (pi-coding-agent.meta) platforms;
    mainProgram = "pi-acp";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
