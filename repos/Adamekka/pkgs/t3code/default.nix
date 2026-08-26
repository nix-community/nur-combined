{ fetchFromGitHub
, fetchPnpmDeps
, lib
, maintainer
, pnpm_11
, rustPlatform
, t3code
,
}:

let
  version = "0.0.34-nightly.20260825.58";

  src = fetchFromGitHub {
    hash = "sha256-OBi1wSUz//gwCXPWL/Y6Z1J6XWr7Q1jQ4y3BX9Xp2yU=";
    owner = "Adamekka";
    repo = "t3code";
    tag = "v${version}";
  };

  t3code-unwrapped = t3code.unwrapped.overrideAttrs (oldAttrs: {
    inherit src version;

    pnpmDeps = fetchPnpmDeps {
      inherit src version;
      inherit (oldAttrs) pname pnpmWorkspaces;
      fetcherVersion = 4;
      hash = "sha256-wXsA9HHr9lppzbMGcQr+2Jq0oqMDtDKhnLhkmVgPIZo=";
      pnpm = pnpm_11;
      # The lockfile includes many optional platform archives, and the registry can take over a minute to serve them.
      prePnpmInstall = ''
        pnpm config set fetch-timeout 600000
      '';
    };

    # The inherited updater edits nixpkgs, while release CI targets this local override explicitly.
    passthru = builtins.removeAttrs oldAttrs.passthru [ "updateScript" ];

    meta = oldAttrs.meta // {
      changelog = "https://github.com/Adamekka/t3code/releases/tag/v${version}";
      downloadPage = "https://github.com/Adamekka/t3code/tags";
      homepage = "https://github.com/Adamekka/t3code";
      maintainers = [ maintainer ];
      platforms = [ "x86_64-linux" ];
    };
  });

  t3code-resource-monitor = rustPlatform.buildRustPackage {
    pname = "t3code-resource-monitor";
    inherit src version;

    cargoHash = "sha256-5cmG2daM1bVOA23gjjoalbx0fEL1hmqV6WZov0sUZp8=";
    sourceRoot = "${src.name}/native/resource-monitor";

    meta = {
      changelog = "https://github.com/Adamekka/t3code/releases/tag/v${version}";
      description = "Native resource diagnostics sidecar for T3 Code";
      homepage = "https://github.com/Adamekka/t3code";
      license = lib.licenses.mit;
      mainProgram = "t3-resource-monitor";
      maintainers = [ maintainer ];
      platforms = [ "x86_64-linux" ];
    };
  };
in
(t3code.override {
  enableAzureDevOps = false;
  enableBitbucket = false;
  enableClaude = false;
  enableCodex = false;
  enableCursor = false;
  enableCursorCli = false;
  enableGit = true;
  enableGitHub = true;
  enableGitLab = false;
  enableJujutsu = false;
  enableOpencode = false;
  enableResourceMonitor = true;
  inherit t3code-resource-monitor t3code-unwrapped;
}).overrideAttrs (oldAttrs: {
  allowSubstitutes = true;

  # symlinkJoin uses a build command directly, so regular install-check phases do not run.
  buildCommand = oldAttrs.buildCommand + ''
    test -x "$out/bin/t3"
    test -x "$out/bin/t3code-desktop"
    test -f "$out/share/applications/t3code.desktop"
    grep -F '${lib.getExe t3code-resource-monitor}' "$out/bin/t3" > /dev/null
    "$out/bin/t3" --help > /dev/null
  '';

  inherit src;
  preferLocalBuild = false;
})
