{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openblas,
  openssl,
  hdf5,
  cmake,
  perl,
  aws-lc,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "runmat";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "runmat-org";
    repo = "runmat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j4YXQwPvnSRzYvJEMROLrN2nIYcl1A0eC0nwpeAHbrE=";
  };

  cargoHash = "sha256-mM5lmYbpbatvaUNciKRNxkuF1xcZpBk/YIIayUnk7O8=";

  nativeBuildInputs = [
    pkg-config
    cmake
    perl
  ];

  buildInputs = [
    aws-lc
    openblas
    openssl
    hdf5
  ];

  # The workspace has 60+ members (LSP, wasm bindings, AOT packer, test
  # runners, miri crates, ...). Only the CLI is shipped, so only build it:
  # compiling every member wastes a lot of CPU time and disk space.
  cargoBuildFlags = [
    "--package"
    "runmat"
    "--bin"
    "runmat"
  ];

  # Keep the build tree small; release builds carry no debug info by default,
  # but make it explicit so a future profile change cannot balloon the build.
  CARGO_PROFILE_RELEASE_DEBUG = "0";

  # The default install phase copies the whole target/<triple>/release tree
  # (including deps/, which is where most of the build artefacts live) into a
  # scratch directory just to pick the executables out of it. That roughly
  # doubles the peak disk usage at the end of the build, which is what makes
  # this package run out of space on CI runners. Install the one binary
  # directly instead.
  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin \
      "$(find target -maxdepth 4 -path '*/release/runmat' -type f -print -quit)"
    runHook postInstall
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source runtime for math. MATLAB syntax";
    homepage = "https://runmat.com/";
    license = lib.licenses.mit;
    mainProgram = "runmat";
  };
})
