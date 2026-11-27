{
  lib,
  stdenvNoCC,
  fetchurl,
  writeShellApplication,
  python3,
  nix-update,
  nix,
  gh,
  git,
}:
let
  sources = {
    x86_64-linux = {
      arch = "x64";
      hash = "sha256-a6b3MTgVfrLpc9YgLmRyg0jgFKzkqZ9xDiyE72zZ8Kc=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-z1e5K6ZNKI7BAbwXJZmSB9PA5hfuN98KHZ8I7mJ3d1M=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fluxdown-server";
  version = "0.6.9";

  src = fetchurl {
    url = "https://github.com/zerx-lab/FluxDown/releases/download/v${finalAttrs.version}/FluxDown-Server-${finalAttrs.version}-linux-${source.arch}.tar.gz";
    inherit (source) hash;
  };

  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 fluxdown-agent fluxdownd -t "$out/bin"
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    (python3.withPackages (packages: [ packages.websocket-client ]))
  ];
  installCheckPhase = ''
    runHook preInstallCheck
    python3 - "$out/bin/fluxdown-agent" ${../../modules/fluxdown-configure.py} ${./settings-schema.json} << 'EOF'
    import os, socket, subprocess, sys, tempfile

    agent, configure, schema = sys.argv[1:4]
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        port = sock.getsockname()[1]
    with tempfile.TemporaryDirectory(prefix="fluxdown-check-") as tmp:
        settings = f"{tmp}/settings.json"
        open(settings, "w").write('{"max_concurrent_tasks": 3}')
        env = os.environ | {
            "HOME": tmp,
            "FLUXDOWN_BIND": f"127.0.0.1:{port}",
            "FLUXDOWN_DATA_DIR": f"{tmp}/state",
            "FLUXDOWN_SAVE_DIR": f"{tmp}/state/downloads",
            "FLUXDOWN_ANALYTICS": "false",
            "FLUXDOWN_MDNS": "false",
        }
        proc = subprocess.Popen([agent, "--server"], env=env, stdout=subprocess.DEVNULL)
        try:
            subprocess.run([sys.executable, configure, settings, schema], env=env, check=True)
        finally:
            proc.terminate()
            proc.wait(timeout=10)
    EOF
    runHook postInstallCheck
  '';

  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-fluxdown-server";
      runtimeInputs = [
        python3
        nix-update
        nix
        gh
        git
      ];
      text = ''
        exec python3 pkgs/fluxdown-server/update.py "$@"
      '';
    });
  };

  meta = {
    description = "Multi-protocol download server with an embedded Web UI";
    homepage = "https://github.com/zerx-lab/FluxDown";
    license = lib.licenses.agpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames sources;
    mainProgram = "fluxdown-agent";
  };
})
