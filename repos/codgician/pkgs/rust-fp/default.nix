{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pam,
  nix-update-script,
  runCommand,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rust-fp";
  # Upstream (acd407/rust-fp) publishes no git tags or GitHub Releases; pin the
  # latest main commit with the unstable version scheme.
  version = "0-unstable-2026-08-01";

  src = fetchFromGitHub {
    owner = "acd407";
    repo = "rust-fp";
    rev = "7036b4dbba82267da85ebb3c10e238186553564c";
    hash = "sha256-vs5aKtbO8AmYuVjc5BJpvn56J5tT9vCwY4RwDJoD9Bo=";
  };

  cargoHash = "sha256-jC1WNyFzVW521HPDrcXITKB+dHxpHLXaMm738lqXavw=";

  strictDeps = true;

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    pam
  ];

  # Virtual workspace: build the CLI, D-Bus daemon, and PAM module crates.
  cargoBuildFlags = [
    "--package"
    "rust-fp-cli"
    "--package"
    "rust-fp-dbus-interface"
    "--package"
    "rust-fp-pam-module"
  ];

  # No unit tests are present in the workspace crates.
  doCheck = false;

  postInstall = ''
    install -Dm644 dbus-interface/org.rust_fp.RustFp.conf \
      $out/share/dbus-1/system.d/org.rust_fp.RustFp.conf

    install -Dm644 rust-fp-dbus-interface.service \
      $out/lib/systemd/system/rust-fp-dbus-interface.service

    substituteInPlace $out/lib/systemd/system/rust-fp-dbus-interface.service \
      --replace-fail /usr/bin/rust-fp-dbus-interface $out/bin/rust-fp-dbus-interface
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch=main"
      ];
    };

    tests.cli-help = runCommand "rust-fp-cli-help" { } ''
      ${lib.getExe finalAttrs.finalPackage} --help | grep -Fq 'Get the maximum number of templates'
      ${lib.getExe finalAttrs.finalPackage} --version | grep -Fq 'rust-fp-cli 1.0.0'
      test -f ${finalAttrs.finalPackage}/lib/librust_fp_pam_module.so
      test -x ${finalAttrs.finalPackage}/bin/rust-fp-dbus-interface
      touch "$out"
    '';
  };

  meta = {
    description = "Fingerprint library, D-Bus interface, CLI, and PAM module for Chromebook fingerprint sensors";
    homepage = "https://github.com/acd407/rust-fp";
    # Upstream ships no LICENSE file or SPDX declaration; treat as unfree.
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "rust-fp";
  };
})
