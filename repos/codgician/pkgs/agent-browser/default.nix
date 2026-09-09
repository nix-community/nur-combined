{
  lib,
  stdenv,
  coreutils,
  fetchFromGitHub,
  fetchPnpmDeps,
  rustPlatform,
  nodejs,
  pnpm_11,
  pnpmConfigHook,
  geist-font,
  nix-update-script,
  which,
  writableTmpDirAsHomeHook,
  makeWrapper,
}:

let
  # Pin the pnpm major so the offline-store layout (and therefore
  # `pnpmDeps.hash`) is stable across nixpkgs bumps of the default `pnpm`
  # attribute. The upstream lockfile is `lockfileVersion: '9.0'`, which is
  # produced by pnpm 9/10/11; pinning to 11 keeps us aligned with what
  # contributors run locally.
  pnpm = pnpm_11.override { nodejs-slim = nodejs; };

  version = "0.37.1";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    tag = "v${version}";
    hash = "sha256-AgpKazIBT3CKd4Q7yQsEGhoTW+7R0Pflma6aH+6UI/U=";
  };

  # The Rust CLI embeds the dashboard UI via RustEmbed at compile time.
  # Build the Next.js static export so it can be placed at the expected path.
  dashboard = stdenv.mkDerivation {
    pname = "agent-browser-dashboard";
    inherit version src;

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
    ];

    __darwinAllowLocalNetworking = true;

    pnpmDeps = fetchPnpmDeps {
      pname = "agent-browser-dashboard";
      inherit version src pnpm;
      pnpmWorkspaces = [ "dashboard" ];
      fetcherVersion = 4;
      hash = "sha256-AEWwJtzmAUspGwFrMqoCvUfefPg2aTvMilBfJPSF9jA=";
    };

    pnpmWorkspaces = [ "dashboard" ];

    # Replace Google Fonts fetch with a local font from nixpkgs since the
    # Nix sandbox has no network access.
    postPatch = ''
      substituteInPlace packages/dashboard/src/app/layout.tsx --replace-fail \
        '{ Geist } from "next/font/google"' \
        'localFont from "next/font/local"'

      substituteInPlace packages/dashboard/src/app/layout.tsx --replace-fail \
        'Geist({ subsets: ["latin"], variable: "--font-sans" })' \
        'localFont({ src: "./Geist-Regular.otf", variable: "--font-sans" })'

      cp "${geist-font}/share/fonts/opentype/Geist-Regular.otf" \
        packages/dashboard/src/app/Geist-Regular.otf
    '';

    buildPhase = ''
      runHook preBuild
      pnpm --filter dashboard build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r packages/dashboard/out $out
      runHook postInstall
    '';
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "agent-browser";
  inherit version src;

  sourceRoot = "${finalAttrs.src.name}/cli";

  cargoHash = "sha256-ziN4UMeEcgsD5BDXWjffreGjyew7oTUtq59b/Um8Dfk=";

  # Place the pre-built dashboard where RustEmbed expects it
  postUnpack = ''
    chmod u+w source/packages/dashboard
    cp -r ${dashboard} source/packages/dashboard/out
  '';

  # `which_exists` spawns the external `which` binary at runtime to probe
  # for optional tools; pin it to an absolute store path.
  postPatch = ''
    substituteInPlace \
      src/doctor/helpers.rs \
      src/install.rs \
      src/native/cdp/chrome.rs \
      src/native/cdp/lightpanda.rs \
      src/native/webdriver/safari.rs \
      --replace-fail \
      '"which"' '"${lib.getExe which}"'
  '';

  nativeCheckInputs = [
    coreutils
    writableTmpDirAsHomeHook
  ];

  nativeBuildInputs = [ makeWrapper ];

  __darwinAllowLocalNetworking = true;

  # Expose bundled skills through the community-standard XDG data path while
  # keeping the CLI's built-in skill commands functional via its env override.
  postInstall = ''
    mkdir -p $out/share/skills/agent-browser
    cp -r ../skills/. $out/share/skills/agent-browser/
    cp -r ../skill-data/. $out/share/skills/agent-browser/
    wrapProgram $out/bin/agent-browser \
      --set AGENT_BROWSER_SKILLS_DIR $out/share/skills/agent-browser
  '';

  passthru = {
    inherit dashboard;
    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "dashboard"
      ];
    };
  };

  meta = {
    description = "Headless browser automation CLI for AI agents";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "agent-browser";
  };
})
