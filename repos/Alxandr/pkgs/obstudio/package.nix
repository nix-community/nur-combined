{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  weaver,
  curl,
  versionCheckHook,
  nix-update-script,
}:

let
  version = "0.1.1";
  src = fetchFromGitHub {
    owner = "signalfx";
    repo = "obstudio";
    tag = "v${version}";
    hash = "sha256-Ml0m/ePAwpIXcCSQq35KZcNT9P3moAAZ9KwL7wMDkMA=";
  };
  client = buildNpmPackage {
    pname = "obstudio-client";
    inherit version src;
    sourceRoot = "source/observer/client";
    npmDepsHash = "sha256-aFxv3rOWpCLdepUvvd73210fmEVFKa6vSN3t+oYGvmc=";
    npmBuildFlags = [
      "--"
      "--outdir"
      "dist"
    ];
    installPhase = ''
      runHook preInstall
      cp -r dist "$out"
      runHook postInstall
    '';
  };
in
buildGoModule {
  pname = "obstudio";
  inherit version src;
  modRoot = "observer";
  vendorHash = "sha256-ubighP8NTlf9gSMRvsdtYVyi6zj3njk53m21iyGZSZk=";
  subPackages = [ "cmd/obstudio" ];

  nativeBuildInputs = [ makeWrapper ];
  outputs = [
    "out"
    "skill"
  ];
  postConfigure = ''
    mkdir -p internal/web/static/assets
    cp -r ${client}/. internal/web/static/assets/
    go run -trimpath=false ./cmd/stage-skills
  '';
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  # The upstream install smoke test copies the vendored source tree.
  preCheck = ''
    chmod -R u+w vendor
  '';

  postInstall = ''
    mkdir -p "$skill"
    cp -r cmd/obstudio/_skills/. "$skill/"
    wrapProgram "$out/bin/obstudio" --prefix PATH : ${lib.makeBinPath [ weaver ]}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    curl
    versionCheckHook
  ];
  versionCheckProgramArg = "--version";
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    export PORT=18888 OTLP_HTTP_PORT=18889 OTLP_GRPC_PORT=18890
    "$out/bin/obstudio" >obstudio.log 2>&1 &
    obstudioPid=$!
    trap 'kill "$obstudioPid" 2>/dev/null || true' EXIT
    ready=
    for _ in $(seq 1 100); do
      if curl --fail --silent http://127.0.0.1:18888/assets/main.js > /dev/null; then
        ready=1
        break
      fi
      if ! kill -0 "$obstudioPid" 2>/dev/null; then
        cat obstudio.log
        exit 1
      fi
      sleep 0.1
    done
    if [ -z "$ready" ]; then
      cat obstudio.log
      exit 1
    fi
    curl --fail --silent --show-error http://127.0.0.1:18888/assets/main.css > /dev/null
    curl --fail --silent --show-error http://127.0.0.1:18888/ | grep -F 'Splunk Observability Studio'
    test -f "$skill/otel-audit/SKILL.md"
    test -d "$skill/references"
    kill "$obstudioPid"
    wait "$obstudioPid" || true
    trap - EXIT
    runHook postInstallCheck
  '';

  passthru = {
    inherit client;
    updateScript = nix-update-script {
      extraArgs = [
        "--use-github-releases"
        "--subpackage"
        "client"
      ];
    };
  };

  meta = {
    description = "Local OpenTelemetry workspace with a web UI, REST API, and MCP server";
    homepage = "https://github.com/signalfx/obstudio";
    license = lib.licenses.asl20;
    mainProgram = "obstudio";
    platforms = lib.platforms.unix;
  };
}
