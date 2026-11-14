{
  lib,
  makeWrapper,
  nasm,
  procps,
  rustPlatform,
  stdenv,
  xdg-utils,
  sources,
}:
let
  inherit (sources.ai-usagebar) src version;
  linuxRuntimePath = lib.makeBinPath [
    procps
    xdg-utils
  ];
in
rustPlatform.buildRustPackage {
  pname = "ai-usagebar";
  inherit src version;

  cargoHash = "sha256-6IHCCe49YiHw8qtVa2uzoOYA9NMl864WayoW48m7dnU=";

  # Upstream's suite shells out to a system `tar` and snapshot files that the
  # sandbox does not provide; package builds only need the two binaries.
  doCheck = false;

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isx86_64 [ nasm ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ makeWrapper ];

  postInstall = ''
    # Unix stub: the tray binary exists so `cargo build --all-targets` is
    # uniform, but it only prints and exits.
    rm -f "$out/bin/ai-usagebar-tray"
    install -Dm644 config.example.toml "$out/share/ai-usagebar/config.example.toml"
    install -Dm644 README.md "$out/share/doc/ai-usagebar/README.md"
    install -Dm644 LICENSE "$out/share/licenses/ai-usagebar/LICENSE"
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    for program in ai-usagebar ai-usagebar-tui; do
      wrapProgram "$out/bin/$program" \
        --prefix PATH : "${linuxRuntimePath}"
    done
  '';

  meta = {
    description = "Multi-provider AI plan usage widget, CLI and TUI";
    homepage = "https://github.com/akitaonrails/ai-usagebar";
    changelog = "https://github.com/akitaonrails/ai-usagebar/releases/tag/${version}";
    license = lib.licenses.mit;
    mainProgram = "ai-usagebar";
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
