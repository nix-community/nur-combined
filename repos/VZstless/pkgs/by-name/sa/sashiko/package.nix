{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  cacert,
  git,
  bash,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sashiko";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "sashiko-dev";
    repo = "sashiko";
    tag = "v.${finalAttrs.version}";
    hash = "sha256-QXm09pKI7+w0VwjBYLMxzdQTsrPQku97e8my1LpqRa4=";
  };

  cargoHash = "sha256-q3Moof35DLnTQEpz+hNCZJrCiQtxBFerLEquJtyNQTo=";

  # Mock worker scripts embedded in reviewer.rs carry a #!/bin/bash shebang
  # and are spawned directly; the sandbox has no /bin/bash, so point them at
  # the store path instead (the scripts use bash-isms like brace expansion,
  # so /bin/sh is not an option).
  postPatch = ''
    substituteInPlace src/reviewer.rs \
      --replace-fail '#!/bin/bash' '#!${bash}/bin/bash'
  '';

  # reqwest fails to build a client in the sandbox without a CA bundle
  # ("No CA certificates were loaded from the system"), which takes out the
  # ~140 tests that spin up an HTTP client against a local test server; the
  # rest of the suite shells out to git, which must be on PATH too.
  nativeCheckInputs = [
    cacert
    git
  ];

  preCheck = ''
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    # Tests run `git init`/`git commit` in temp dirs; git refuses to operate
    # without an identity and without a writable HOME.
    export HOME=$(mktemp -d)
    git config --global user.name "nixbld"
    git config --global user.email "nixbld@example.com"
    git config --global init.defaultBranch main
    # The toolbox tests treat this source tree itself as a git checkout
    # (git log/blame/show on "this repository's own README"); the fetched
    # tarball has no .git, so give them a single-commit repo. target/ is
    # covered by the upstream .gitignore.
    git init
    git add -A
    git commit -m "packaging test commit"
    # buildRustPackage exports RUST_LOG="" for quieter builds, but sashiko's
    # main.rs lets RUST_LOG override the --debug flag; an empty-but-set
    # RUST_LOG silences every log line and breaks the --debug integration
    # test, so restore the flag's authority.
    unset RUST_LOG
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Agentic review of Linux Kernel code changes";
    homepage = "https://sashiko.dev";
    license = lib.licenses.asl20;
    mainProgram = "sashiko";
  };
})
