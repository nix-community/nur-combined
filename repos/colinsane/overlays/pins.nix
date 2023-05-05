# when a `nixos-rebuild` fails after a nixpkgs update:
# - take the failed package
# - search it here: <https://hydra.nixos.org/search?query=pkgname>
# - if it's broken by that upstream builder, then pin it: somebody will come along and fix the package.
# - otherwise, search github issues/PRs for knowledge of it before pinning.
# - if nobody's said anything about it yet, probably want to root cause it or hold off on updating.
#
# note that these pins apply to *all* platforms:
# - natively compiled packages
# - cross compiled packages
# - qemu-emulated packages

(next: prev: {
  # XXX: when invoked outside our flake (e.g. via NIX_PATH) there is no `next.stable`,
  # so just forward the unstable packages.
  inherit (next.stable or prev)
  ;
  # chromium can take 4 hours to build from source, with no signs of progress.
  # disable it if you're in a rush.
  # chromium = next.emptyDirectory;

  # lemmy-server = prev.lemmy-server.overrideAttrs (upstream: {
  #   patches = upstream.patches or [] ++ [
  #     (next.fetchpatch {
  #       # "Fix docker federation setup (#2706)"
  #       url = "https://github.com/LemmyNet/lemmy/commit/2891856b486ad9397bca1c9839255d73be66361.diff";
  #       hash = "sha256-qgRvBO2y7pmOWdteu4uiZNi8hs0VazOV+L5Z0wu60/E=";
  #     })
  #   ];
  # });
  lemmy-server = prev.lemmy-server.overrideAttrs (upstream: {
    patches = upstream.patches or [] ++ [
      # "thread 'main' panicked at 'Couldn't run DB Migrations: Failed to run 2022-07-07-182650_comment_ltrees with: permission denied: "RI_ConstraintTrigger_a_647340" is a system trigger', crates/db_schema/src/utils.rs:165:25"
      (next.writeText "fix-db-migrations" ''
        diff --git a/migrations/2022-07-07-182650_comment_ltrees/up.sql b/migrations/2022-07-07-182650_comment_ltrees/up.sql
        index fde9e1b3..55b96dac 100644
        --- a/migrations/2022-07-07-182650_comment_ltrees/up.sql
        +++ b/migrations/2022-07-07-182650_comment_ltrees/up.sql
        @@ -60,7 +60,7 @@ ORDER BY
                breadcrumb;

         -- Remove indexes and foreign key constraints, and disable triggers for faster updates
        -alter table comment disable trigger all;
        +-- alter table comment disable trigger all;

         alter table comment drop constraint if exists comment_creator_id_fkey;
         alter table comment drop constraint if exists comment_parent_id_fkey;
        @@ -115,4 +115,4 @@ create index idx_path_gist on comment using gist (path);
         -- Drop the parent_id column
         alter table comment drop column parent_id cascade;

        -alter table comment enable trigger all;
        +-- alter table comment enable trigger all;
      '')
    ];
  });
})
