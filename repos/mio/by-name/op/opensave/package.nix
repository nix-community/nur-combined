{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchNpmDeps,
  npmHooks,
  nodejs_22,
  nix-update-script,
  pkg-config,
  writeShellApplication,
  wails,
  gtk3,
  webkitgtk_4_1,
}:

buildGoModule (finalAttrs: {
  pname = "opensave";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "Liquid-co";
    repo = "OpenSave";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dxz9zQo7oeRgHmi4JM4iojiFMb0wM3h93Qk/8FTHkp8=";
  };

  vendorHash = "sha256-U2Rz0nn/DXkXboORlGaViZ8K3cfMniQ0eNCj7kY6nrU=";

  # buildGoModule shares nativeBuildInputs with the Go module FOD, but that
  # derivation has no npmDeps of its own; the frontend hook belongs to the
  # main build only.
  overrideModAttrs = _: previousAttrs: {
    nativeBuildInputs = lib.filter (
      drv: (drv.name or "") != "npm-config-hook"
    ) previousAttrs.nativeBuildInputs;
  };

  npmRoot = "cmd/opensave-app/frontend";
  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    postPatch = ''
      cp cmd/opensave-app/frontend/package-lock.json package-lock.json
    '';
    hash = "sha256-5Tq52Rz/hmunrslINqn8G89z6hI9dBE3UEFaqhDFZOQ=";
  };

  nativeBuildInputs = [
    nodejs_22
    npmHooks.npmConfigHook
    pkg-config
    wails
  ];

  buildInputs = [
    gtk3
    webkitgtk_4_1
  ];

  buildPhase = ''
    runHook preBuild

    npm --prefix cmd/opensave-app/frontend run build

    pushd cmd/opensave-app >/dev/null
    wails build \
      -s \
      -skipbindings \
      -m \
      -nosyncgomod \
      -trimpath \
      -tags webkit2_41 \
      -ldflags "-s -w -X github.com/opensave/opensave/internal/version.Version=${finalAttrs.version}"
    popd >/dev/null

    mkdir -p .opensave-bin
    go build -trimpath -ldflags "-s -w -X github.com/opensave/opensave/internal/version.Version=${finalAttrs.version}" \
      -o .opensave-bin/opensave-cli ./cmd/opensave-cli
    go build -trimpath -ldflags "-s -w -X github.com/opensave/opensave/internal/version.Version=${finalAttrs.version}" \
      -o .opensave-bin/opensave-relay ./cmd/opensave-relay

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 cmd/opensave-app/build/bin/OpenSave $out/bin/opensave
    install -Dm755 .opensave-bin/opensave-cli $out/bin/opensave-cli
    install -Dm755 .opensave-bin/opensave-relay $out/bin/opensave-relay
    ln -s opensave-cli $out/bin/os

    install -Dm644 cmd/opensave-app/build/linux/opensave.desktop \
      $out/share/applications/opensave.desktop
    install -Dm644 cmd/opensave-app/build/appicon.png \
      $out/share/icons/hicolor/512x512/apps/opensave.png
    install -Dm644 packaging/man/opensave.1 $out/share/man/man1/opensave.1
    install -Dm644 packaging/systemd/opensave-daemon-native.service \
      $out/share/systemd/user/opensave-daemon.service
    substituteInPlace $out/share/systemd/user/opensave-daemon.service \
      --replace-fail /usr/bin/opensave-cli $out/bin/opensave-cli

    install -Dm644 <(.opensave-bin/opensave-cli completion bash) \
      $out/share/bash-completion/completions/opensave
    install -Dm644 <(.opensave-bin/opensave-cli completion zsh) \
      $out/share/zsh/site-functions/_opensave
    install -Dm644 <(.opensave-bin/opensave-cli completion fish) \
      $out/share/fish/vendor_completions.d/opensave.fish

    runHook postInstall
  '';

  # Upstream's test suite is the long-running daemon/e2e suite from CI: it
  # starts peers and binds real ports, so it is not part of this build gate.
  doCheck = false;

  passthru.updateScript = writeShellApplication {
    name = "update-opensave";
    text = ''
      export UPDATE_NIX_ATTR_PATH="opensave"
      exec ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [
            "--version-regex"
            "v(.*)"
          ];
        })
      } "$@"
    '';
  };

  meta = {
    description = "Peer-to-peer game save sync";
    longDescription = ''
      OpenSave syncs game saves between your own devices over the LAN or
      through a relay, with versioned snapshots and conflict handling. Includes
      the Wails desktop app, the headless CLI, and a relay server.
    '';
    homepage = "https://github.com/Liquid-co/OpenSave";
    downloadPage = "https://github.com/Liquid-co/OpenSave/releases";
    changelog = "https://github.com/Liquid-co/OpenSave/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "opensave";
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
