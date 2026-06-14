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
  version = "2.9.1-unstable-2026-06-13";
  rev = "1b42270f6d46dcb5cae30be89c7725c63756dc1f";

  src = fetchFromGitHub {
    owner = "gotify";
    repo = "server";
    inherit rev;
    hash = "sha256-1z29zgsimrMooblpgaWrfwFvPxs4yBCP0Z+Wod6hyG4=";
  };

  ui = stdenvNoCC.mkDerivation {
    pname = "gotify-ui";
    inherit version;

    src = "${src}/ui";

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${src}/ui/yarn.lock";
      hash = "sha256-Oxhg0fDwdHrUwLkrkH0s6oiLUkHG6gH8FUmZM/Wcecc=";
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

    vendorHash = "sha256-jKChHnruWZgkBxWfOFgg/SQ5e7uhrklc8MrBlhX1SZ8=";
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
