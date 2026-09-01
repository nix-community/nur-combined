{
  lib,
  rustPlatform,
  cmake,
  pkg-config,
  fetchFromGitHub,
  libgit2,
  openssl,
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
  version = "0.22.3";

  src = fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "gitbutler";
    tag = "release/${finalAttrs.version}";
    hash = "sha256-nW3yCbpbIhawLQVV+DptzGYiFBSKcyAP89NtDWHJM+0=";
  };

  cargoHash = "sha256-XRc2yok9K7f/vRAqgO78JUq/U36XSiUeOINupfOOSjw=";

  nativeBuildInputs = [
    cmake # Required by `zlib-sys` crate
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    libgit2Experimental
    openssl
    glib
    dbus
  ];

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
