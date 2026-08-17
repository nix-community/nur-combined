{
  cmake,
  fetchFromGitHub,
  lib,
  monero-cli,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cuprate";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "Cuprate";
    repo = "cuprate";
    tag = "cuprated-${finalAttrs.version}";
    hash = "sha256-j7swVsxOk52tRrxEBMJLPJgt/btWBXY+xJ5LSYxDHgY=";
    leaveDotGit = true;
    postFetch = ''
      cd $out
      git rev-parse HEAD > COMMIT
      rm -rf .git
    '';
  };

  cargoHash = "sha256-NDZb/DLNP35EKqsoLz/AallYyeHcm9M+DtNxZzq+PFQ=";

  checkFlags = [
    "--skip=rpc::client::tests::localhost" # Failed
  ];

  postPatch = ''
    export GITHUB_SHA="$(cat COMMIT)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  preCheck = ''
    ln -s ${monero-cli}/bin/monerod monerod
  '';

  env = {
    # https://docs.rs/openssl/latest/openssl/
    OPENSSL_NO_VENDOR = 1;
    # https://doc.rust-lang.org/beta/unstable-book/compiler-environment-variables/RUSTC_BOOTSTRAP.html
    RUSTC_BOOTSTRAP = 1;
  };

  strictDeps = true;

  __structuredAttrs = true;

  meta = {
    description = "Modular Monero node written in Rust";
    homepage = "https://cuprate.org";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "cuprated";
    platforms = lib.platforms.linux;
  };
})
