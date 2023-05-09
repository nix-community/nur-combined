{ lemmy-server }:

lemmy-server.overrideAttrs (upstream: {
  patches = upstream.patches or [] ++ [
    # "thread 'main' panicked at 'Couldn't run DB Migrations: Failed to run 2022-07-07-182650_comment_ltrees with: permission denied: "RI_ConstraintTrigger_a_647340" is a system trigger', crates/db_schema/src/utils.rs:165:25"
    ./fix-db-migrations.patch
    ./log-startup.patch
  ];
})
