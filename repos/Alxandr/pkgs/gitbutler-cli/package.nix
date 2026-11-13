{
  lib,
  rustPlatform,
  rustc,
  cmake,
  pkg-config,
  fetchFromGitHub,
  libgit2,
  openssl,
  aws-lc,
  oniguruma,
  sqlite,
  git,
  glib,
  dbus,
  nix-update-script,
  installShellFiles,
  ...
}:

let
  cargoFlags = [
    "-p"
    "but"
  ];

  libgit2Experimental = libgit2.override {
    withExperimentalSha256 = true;
  };

in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gitbutler-cli";
  version = "0.23.2";

  src = fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "gitbutler";
    tag = "release/${finalAttrs.version}";
    hash = "sha256-JLsIlkbNRqjCgidgI33djWcseGkwsEBzw6g9q6eYoDg=";
  };

  cargoHash = "sha256-Q+or42ppjjkt4OEc+cC2knTCkB7XloePpt2beHYG4q4=";

  nativeBuildInputs = [
    cmake # Required by `zlib-sys` crate
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    libgit2Experimental
    openssl
    aws-lc
    oniguruma
    sqlite
    glib
    dbus
  ];

  # autoreview: 2026-11-13-rust-llvm-vnni
  # Rust >= 1.98 uses the LLVM >= 22 VNNI intrinsic signatures.
  postPatch =
    lib.optionalString
      (lib.versionAtLeast rustc.version "1.98" && lib.versionOlder rustc.llvmPackages.llvm.version "22")
      ''
        patch -d "$cargoDepsCopy/source-registry-0/adler32furious-0.1.1" -p1 \
          < ${./adler32furious-llvm21.patch}
      '';

  nativeCheckInputs = [ git ];

  dontCargoCheck = true; # Who cares about tests?
  cargoBuildFlags = cargoFlags;

  env = {
    OPENSSL_NO_VENDOR = true;
    VERSION = finalAttrs.version;
  }
  // lib.optionalAttrs (lib.versionAtLeast libgit2Experimental.version "1.9.4") {
    LIBGIT2_NO_VENDOR = 1;
  };

  outputs = [
    "out"
    "skill"
  ];

  postInstall = ''
    export XDG_CONFIG_HOME="$TMPDIR/home/config"
    mkdir -p "$XDG_CONFIG_HOME"

    installShellCompletion --cmd but \
      --bash <($out/bin/but completions bash) \
      --fish <($out/bin/but completions fish) \
      --zsh <($out/bin/but completions zsh)

    mkdir -p "$skill"
    $out/bin/but skill install --path "$skill"
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--use-github-releases"
        "--version-regex"
        "release/(.*)"
      ];
    };
  };

  meta = {
    description = "Command-line interface for GitButler";
    homepage = "https://gitbutler.com";
    license = lib.licenses.fsl11Mit;
    platforms = lib.platforms.linux;
    mainProgram = "but";
  };
})
