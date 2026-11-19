{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  stdenv,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "koh";
  version = "0.17.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "gold-silver-copper";
    repo = "koh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M6npP9MMq+QO9xyVi9aiTfDP6GUK5F6g0M5wKMrazik=";
  };

  cargoHash = "sha256-jUpKySeaLR2n+9Af4U7nMToPPKOWMWHQjm2QRMqwASs=";

  checkFlags = lib.cli.toCommandLineGNU {} {
    skip =
      (lib.optional stdenv.hostPlatform.isLinux "sync::tests::a_tree_lands_then_only_what_changed_is_sent_and_gets_its_arrival_time")
      ++ (lib.optionals stdenv.hostPlatform.isDarwin [
        "a_long_line_written_in_one_go_runs_with_nothing_typed_after"
        "a_prompt_printed_before_echo_goes_off_is_never_told_with_echo_on"
        "a_server_whose_clients_went_at_any_point_serves_the_next"
        "a_sessions_bash_marks_its_commands_after_the_users_bashrc"
        "serve_without_allow_allows_the_saved_clients"
        "session::scrolled_off_output_is_in_the_terminals_scrollback_and_a_fresh_attachs"
        "the_shell_leads_its_own_session_and_owns_its_terminal"
      ]);
  };

  passthru.updateScript = nix-update-script {extraArgs = ["--use-github-releases"];};

  meta = {
    description = "Peer-to-peer remote shell, inspired by mosh";
    homepage = "https://github.com/gold-silver-copper/koh";
    changelog = "https://github.com/gold-silver-copper/koh/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [lib.maintainers.examosa];
    mainProgram = "koh";
  };
})
