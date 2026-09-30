{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "tunnet";
  version = "0.9.1-unstable-2026-09-26";

  # Tracks upstream main; bump rev/version/hash/cargoHash by hand.
  src = fetchFromGitHub {
    owner = "tunnetio";
    repo = "Tunnet";
    rev = "f9f9021c277eb9b631ae1558493236b557df45a2";
    hash = "sha256-8RXHB2Kov9J37E8uPjHIe9HUxnGGiBo4gy3GwgJFMRE=";
  };

  cargoHash = "sha256-PSuQkEEficx0dm9DT6bXhhDxUvU66gNkrAqpsXXFZ5s=";

  # Upstream links x86_64-gnu with mold (-fuse-ld=mold), which is not in the build env.
  postPatch = ''
    rm .cargo/config.toml
  '';

  # Same crates as upstream's tunnet-headless release: tunnetd (tunnet-agent) and tunnet (tunnet-cli).
  cargoBuildFlags = [
    "-p"
    "tunnet-agent"
    "-p"
    "tunnet-cli"
  ];

  # cargo test would build the whole workspace, including the Tauri desktop app; upstream CI runs the suite.
  doCheck = false;

  postInstall = ''
    install -Dm644 LICENSE -t $out/share/doc/tunnet
    cp -r licenses $out/share/doc/tunnet/
  '';

  meta = {
    description = "Encrypted peer-to-peer mesh network agent (latest upstream commit)";
    longDescription = ''
      Tunnet builds an encrypted overlay network over QUIC (iroh) in which every machine
      gets an internal mesh IP and can reach every other machine. This package ships the
      mesh CLI (tunnet) and the agent daemon (tunnetd).

      tunnetd needs root (or CAP_NET_ADMIN) and /dev/net/tun. Do not use
      `tunnet service install` on NixOS: it writes /etc/systemd/system/tunnet.service.
      Use the services.tunnet module from this repository instead. Likewise `tunnet update`
      rewrites its own binary and cannot work from the Nix store; update the package.
    '';
    homepage = "https://tunnet.io";
    license = with lib.licenses; [
      mpl20
      asl20
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "tunnet";
  };
}
