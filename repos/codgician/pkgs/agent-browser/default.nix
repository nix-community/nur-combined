{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  rustPlatform,
  nodejs_22,
  pnpm_11,
  pnpmConfigHook,
  geist-font,
  nix-update-script,
  which,
  writableTmpDirAsHomeHook,
}:

let
  # Pin the pnpm major so the offline-store layout (and therefore
  # `pnpmDeps.hash`) is stable across nixpkgs bumps of the default `pnpm`
  # attribute. The upstream lockfile is `lockfileVersion: '9.0'`, which is
  # produced by pnpm 9/10/11; pinning to 11 keeps us aligned with what
  # contributors run locally.
  #
  # Pin Node.js 22 for the JS toolchain. Node.js 24 crashes on macOS with
  # `EXC_GUARD` (`GUARD_TYPE_FD`) during `pnpm install`/`pnpm build`: pnpm's
  # reflink worker (APFS clonefile) closes a file descriptor that Node 24's
  # new BSD file-descriptor guard treats as managed, so the kernel kills the
  # process. This only affects the build-time dashboard tooling, not the
  # runtime CLI, and the FOD `pnpmDeps.hash` is unaffected by the Node major.
  nodejs = nodejs_22;
  pnpm = pnpm_11.override { nodejs-slim = nodejs; };

  version = "0.31.2";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    tag = "v${version}";
    hash = "sha256-BUXa1Le/AtKR2Gxin6eTG6FSrDVaMtceYrOKkQmk5Jo=";
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
      hash = "sha256-GAjgtLUXPa6OaSvq7PQVp0RIHMIDKcgbFbt6TFwx11g=";
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

  cargoHash = "sha256-ee8c0v3ZYZLMJReZyO7LAknUEysG84Z9wfSZlQTXNKU=";

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
    writableTmpDirAsHomeHook
  ];

  __darwinAllowLocalNetworking = true;

  # The `skills` subcommand looks for `skills/` and `skill-data/` next to
  # `bin/`, relative to the canonical exe path. See cli/src/skills.rs.
  postInstall = ''
    cp -r ../skills $out/skills
    cp -r ../skill-data $out/skill-data
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
