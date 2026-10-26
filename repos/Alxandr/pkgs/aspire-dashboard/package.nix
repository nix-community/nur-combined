{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  autoPatchelfHook,
  clang,
  openssl,
  zlib,
  curl,
  nix-update-script,
}:

buildDotnetModule (finalAttrs: {
  pname = "aspire-dashboard";
  version = "13.6.1";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "aspire";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q6OXFUFai3swj1vnoL1UWmFwR7wqeB1i5oAnHphkSfI=";
  };

  projectFile = "src/Aspire.Dashboard/Aspire.Dashboard.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_11_0;
  dotnet-runtime = null;
  runtimeId = "linux-x64";
  selfContainedBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    clang
  ];
  buildInputs = [ zlib ];
  runtimeDeps = [ openssl ];

  executables = [ "Aspire.Dashboard" ];

  postFixup = ''
    mv "$out/bin/Aspire.Dashboard" "$out/bin/aspire-dashboard"
    wrapProgram "$out/bin/aspire-dashboard" \
      --chdir "$out/lib/aspire-dashboard"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ curl ];
  installCheckPhase = ''
    runHook preInstallCheck

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"

    export ASPNETCORE_URLS=http://127.0.0.1:18888
    export DOTNET_DASHBOARD_OTLP_ENDPOINT_URL=http://127.0.0.1:18889
    export DOTNET_DASHBOARD_OTLP_HTTP_ENDPOINT_URL=http://127.0.0.1:18890
    export DOTNET_DASHBOARD_UNSECURED_ALLOW_ANONYMOUS=true

    "$out/bin/aspire-dashboard" >dashboard.log 2>&1 &
    dashboardPid=$!
    trap 'kill "$dashboardPid" 2>/dev/null || true' EXIT

    dashboardReady=
    for _ in $(seq 1 50); do
      if curl --fail --silent --show-error http://127.0.0.1:18888/css/design.css > /dev/null; then
        dashboardReady=1
        break
      fi
      if ! kill -0 "$dashboardPid" 2>/dev/null; then
        cat dashboard.log
        exit 1
      fi
      sleep 0.1
    done

    if [ -z "$dashboardReady" ]; then
      cat dashboard.log
      exit 1
    fi

    curl --fail --silent --show-error --location http://127.0.0.1:18888/ \
      | grep -F 'name="dotnet-runtime-mode" content="AOT"'

    curl --fail --silent --show-error \
      http://127.0.0.1:18888/Aspire.Dashboard.styles.css \
      > /dev/null
    curl --fail --silent --show-error \
      http://127.0.0.1:18888/_framework/blazor.web.js \
      > /dev/null
    curl --fail --silent --show-error \
      http://127.0.0.1:18888/_content/Microsoft.FluentUI.AspNetCore.Components/css/reboot.css \
      > /dev/null

    kill "$dashboardPid"
    wait "$dashboardPid" || true
    trap - EXIT

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--use-github-releases" ];
  };

  meta = {
    description = "Standalone dashboard for visualizing OpenTelemetry data";
    homepage = "https://aspire.dev/dashboard/standalone/";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "aspire-dashboard";
  };
})
