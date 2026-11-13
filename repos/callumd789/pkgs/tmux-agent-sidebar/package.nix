{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tmux-agent-sidebar";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "hiroppy";
    repo = "tmux-agent-sidebar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NiqLgMvWbSW3M80ZUWdmmm2VkVqy8eTGcPkrOCsaasI=";
  };

  cargoHash = "sha256-mOEs2J1o9VeVOXY55r8O52TqoM2GuYU3tVoh5h+yH0s=";

  checkFlags = [
    # These expect the source tree to be a git checkout, and the fetched
    # tarball has no .git directory.
    "--skip=group::tests::resolve_git_info_for_real_repo"
    "--skip=group::tests::worktree_and_main_share_same_repo_root"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tmux sidebar that monitors AI coding agents across all windows and sessions";
    homepage = "https://github.com/hiroppy/tmux-agent-sidebar";
    changelog = "https://github.com/hiroppy/tmux-agent-sidebar/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    mainProgram = "tmux-agent-sidebar";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
