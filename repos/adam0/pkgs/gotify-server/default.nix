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
  version = "2.9.1-unstable-2026-06-09";
  rev = "0e32e56f6736bf6640120429827eb64f76fe97fb";

  src = fetchFromGitHub {
    owner = "gotify";
    repo = "server";
    inherit rev;
    hash = "sha256-omFRx8K4acny51muuY8c8TrC6PTQs9k5egzMpnp6wAY=";
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
