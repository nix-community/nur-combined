{
  source,
  lib,
  rustPlatform,
  perl,
}:

rustPlatform.buildRustPackage {
  inherit (source)
    pname
    version
    src
    ;

  cargoLock = source.cargoLock."Cargo.lock";

  nativeBuildInputs = [ perl ];

  checkFlags = [
    "--skip=git::status::tests::test_clean_submodule_not_reported"
    "--skip=git::status::tests::test_dirty_submodule_makes_repo_dirty"
    "--skip=git::status::tests::test_dirty_submodule_with_real_git_submodule"
    "--skip=git::status::tests::test_ignore_dirty_subs_hides_submodule_state"
    "--skip=git::status::tests::test_submodule_modified_pointer"
    "--skip=git::status::tests::test_worktree_info_reflects_linked_worktrees"
  ];

  meta = {
    description = "Multi-repo Git workspace dashboard for the terminal";
    homepage = "https://github.com/affromero/gitpane";
    license = lib.licenses.mit;
  };
}
