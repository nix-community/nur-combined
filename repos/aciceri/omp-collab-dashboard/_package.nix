{
  writers,
  lib,
}:
(writers.writePython3Bin "omp-collab-dashboard" { } (builtins.readFile ./omp-collab-dashboard.py)).overrideAttrs
  (oldAttrs: {
    version = "1.0.0";
    meta = oldAttrs.meta or { } // {
      description = "Dashboard listing active omp collab sessions";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.aciceri ];
    };
  })
