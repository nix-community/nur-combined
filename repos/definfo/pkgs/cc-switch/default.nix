{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm,
  pkg-config,
  cargo-tauri,
  wrapGAppsHook3,
  nodejs,
  openssl,
  libsoup_3,
  webkitgtk_4_1,
  libayatana-appindicator,
  jq,
  moreutils,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cc-switch";
  version = "3.11.1";

  src = fetchFromGitHub {
    owner = "farion1231";
    repo = "cc-switch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-x3kPrsPMk3itu5D9BWSMk5KLSIiL68HTn14yHVdAh8c=";
  };

  cargoHash = "sha256-+zp3YvXFzMozX6z04GWXEoQ1waWxY1nASM95jQ9e050=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-G8Qw2Gs57FNoK+Jr5Yeq6K9XFH0+DrRNiliNPu966pk=";
  };

  postPatch = ''
    substituteInPlace $cargoDepsCopy/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"

    ${lib.getExe jq} '
      .bundle = (.bundle // {}) |
      .bundle.createUpdaterArtifacts = false |
      del(.plugins.updater)
    ' src-tauri/tauri.conf.json \
      | ${lib.getExe' moreutils "sponge"} src-tauri/tauri.conf.json
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    pkg-config
    pnpmConfigHook
    rustPlatform.bindgenHook
    wrapGAppsHook3
    nodejs
    pnpm
  ];

  buildInputs = [
    openssl
    libsoup_3
    webkitgtk_4_1
    libayatana-appindicator
  ];

  checkFlags = map (t: "--skip ${t}") [
    # need network connection
  ];

  # Set our Tauri source directory
  cargoRoot = "src-tauri";
  # And make sure we build there too
  buildAndTestSubdir = finalAttrs.cargoRoot;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=v(.*)" ]; };

  meta = {
    description = "An assistant tool for SJTU Canvas online course platform";
    homepage = "https://github.com/Okabe-Rintarou-0/SJTU-Canvas-Helper";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ definfo ];
  };
})
