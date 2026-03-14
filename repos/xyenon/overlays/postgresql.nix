_final: prev:

let
  inherit (prev) lib;

  postgresqlDefs = import "${prev.path}/pkgs/servers/sql/postgresql/default.nix" prev;

  patchPostgresql =
    _: pkg:
    pkg.overrideAttrs (
      old:
      let
        pg_search = prev.nur.repos.xyenon.pg_search.override { postgresql = pkg; };
      in
      {
        passthru = (old.passthru or { }) // {
          pkgs = (old.passthru.pkgs or { }) // {
            inherit pg_search;
          };
          withPackages = f: old.passthru.withPackages (ps: f (ps // { inherit pg_search; }));
        };
      }
    );
in
lib.mapAttrs patchPostgresql (
  postgresqlDefs.postgresqlVersions // postgresqlDefs.postgresqlJitVersions
)
