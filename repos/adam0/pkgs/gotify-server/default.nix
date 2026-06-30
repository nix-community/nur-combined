{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  fetchYarnDeps,
  lib,
  nodejs-slim,
  sqlite,
  stdenvNoCC,
  yarnBuildHook,
  yarnConfigHook,
  # keep-sorted end
}: let
  version = "2.9.1-unstable-2026-06-29";
  rev = "e4018b44e2a6122ddeed85e72e1ad3496b12df1f";

  src = fetchFromGitHub {
    owner = "gotify";
    repo = "server";
    inherit rev;
    hash = "sha256-j1Ubb96cGfAiNtEAnORuB2zJt+oQtGx7RV9Q0CLyKdI=";
  };

  ui = stdenvNoCC.mkDerivation {
    pname = "gotify-ui";
    inherit version;

    src = "${src}/ui";

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${src}/ui/yarn.lock";
      hash = "sha256-NzAGtVTd7PXsD9vLJmHC9CPF98ewwAS0PvsQT+fWcAo=";
    };

    nativeBuildInputs = [
      # keep-sorted start
      nodejs-slim
      yarnBuildHook
      yarnConfigHook
      # keep-sorted end
    ];

    env.NODE_OPTIONS = "--openssl-legacy-provider";

    installPhase = ''
      runHook preInstall

      mv build $out

      runHook postInstall
    '';
  };
in
  buildGoModule {
    pname = "gotify-server";
    inherit src version;

    vendorHash = "sha256-+EYK7lMVK0696EW1CNp0Wvn7+tpd3TtiO2BFkGzDu1M=";
    proxyVendor = true;

    # keep-sorted start
    buildInputs = [sqlite];
    doCheck = false;
    # keep-sorted end

    preConfigure = ''
      cp -r ${ui} ui/build
    '';

    subPackages = ["."];

    ldflags = [
      "-s"
      "-X main.Version=${version}"
      "-X main.Mode=prod"
      "-X main.Commit=${rev}"
      "-X main.BuildDate=unknown"
    ];

    meta = {
      # keep-sorted start
      description = "Simple server for sending and receiving messages in real-time per WebSocket (nightly)";
      homepage = "https://gotify.net";
      license = lib.licenses.mit;
      mainProgram = "server";
      platforms = lib.platforms.linux;
      # keep-sorted end
    };

    passthru = {
      inherit rev;
    };
  }
