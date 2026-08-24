{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "npr";
  version = "0-unstable-2026-05-28";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "npr";
    rev = "a80abbaf521216b454909550a786d0f37273599e";
    hash = "sha256-RbSSFW8hMn6pBo6rnWeFwtLtNPAldlQaceNh0mMQErQ=";
  };
  cargoHash = "sha256-9kgSGCKsHt44S+4iP2EOyvV5Nox0jhFu/+8c1o7ROaU=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Pull request tracker for Nixpkgs";
    homepage = "https://github.com/manic-systems/npr";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "npr";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
