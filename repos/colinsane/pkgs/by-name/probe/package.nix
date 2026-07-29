{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "probe";
  version = "0.6.0-rc327";

  src = fetchFromGitHub {
    owner = "probelabs";
    repo = "probe";
    rev = "v${finalAttrs.version}";
    hash = "sha256-dQMnmAR84O67YPAJEMimQC6ObnJFlLPfBmAJmz9tAtI=";
  };

  # upstream does not ship a Cargo.lock, so we provide our own (generated with
  # `cargo generate-lockfile` at the pinned rev).
  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "tree-sitter-crystal-0.0.1" = "sha256-f0/i9JHYWeif9xeZPKNacEnwcp6mPRRfFZ90I3lRgW8=";
      "turso-0.3.0-pre.3" = "sha256-jiPoNgwgKWvLVyWzR9GAgeuMsEZ6Xwm9xV7gLhBU01c=";
    };
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  # upstream distributes only the `probe` binary;
  # `debug-tree-sitter` and `position-analyzer` are dev utilities.
  cargoBuildFlags = [
    "--bin"
    "probe"
  ];

  # the test suite requires external language servers (gopls,
  # typescript-language-server, ...) and network access.
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "AI-friendly, fully local, semantic code search tool for large codebases";
    homepage = "https://github.com/probelabs/probe";
    license = lib.licenses.asl20;
    mainProgram = "probe";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})