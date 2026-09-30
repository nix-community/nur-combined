{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oryx";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "wmahfoudh";
    repo = "oryx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2kqW4D7rgI3RFYxqTEFWK0Q4OPw57yplpaKXcGe10dE=";
  };

  cargoHash = "sha256-vfkVbMw+YeUPNehHvr+7Pq8idx4nWrZK2yUSP1NesC4=";

  buildInputs = [
    openssl
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  # The sandbox HOME (/homeless-shelter) does not exist, which makes
  # platform::config::tests::the_home_folder_is_the_last_candidate_before_the_working_directory
  # fail on `assert!(home.is_dir())`.
  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  # These packaging self-checks compare upstream's checked-in AUR PKGBUILDs /
  # flathub manifest against the newest stable metainfo release. At the v1.2.0
  # tag those files still reference v1.1.1, so they fail on upstream's own
  # source; nothing to do with this build.
  checkFlags = [
    "--skip=the_source_pkgbuild_builds_the_tag_of_the_last_release_and_conflicts_with_oryx"
    "--skip=the_bin_pkgbuild_fetches_the_release_files_and_provides_oryx_editor"
    "--skip=the_flathub_manifest_builds_the_tag_offline_into_app"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast, native and beautiful desktop viewer & editor for markdown and code";
    homepage = "https://github.com/wmahfoudh/oryx";
    license = lib.licenses.gpl3Plus;
    mainProgram = "oryx";
  };
})
