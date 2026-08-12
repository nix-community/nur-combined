{
  writeShellScriptBin,
  bun,
  lib,
}:
(writeShellScriptBin "omp-collab-relay" ''
  exec ${lib.getExe bun} run ${./omp-collab-relay.ts} "$@"
'').overrideAttrs
  (oldAttrs: {
    version = "1.0.0";
    meta = oldAttrs.meta or { } // {
      description = "Self-hosted relay for omp collab E2E-encrypted session sharing";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.aciceri ];
    };
  })
