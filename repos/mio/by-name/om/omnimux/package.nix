{
  lib,
  stdenv,
  rustPlatform,
  buildNpmPackage,
  pkg-config,
  webkitgtk_4_1,
  glib,
  openssl,
  cargo-tauri,
  wrapGAppsHook3,
}:

let
  frontend = buildNpmPackage {
    pname = "omnimux-ui";
    version = "0.1.0";
    src = ./src;
    npmDepsHash = "sha256-N2CMOKjrkJWD5tAEgA2pVergl938OIIE/pUziMKbSNo=";
  };
in
rustPlatform.buildRustPackage {
  pname = "omnimux";
  version = "0.1.0";

  src = ./src/src-tauri;

  cargoLock = {
    lockFile = ./src/src-tauri/Cargo.lock;
  };

  nativeBuildInputs = [
    pkg-config
    cargo-tauri.hook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook3
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    webkitgtk_4_1
    glib
  ];

  # cargo-tauri.hook replaces the build and install phases, so we need to make sure they are used
  # instead of cargoBuildHook / cargoInstallHook.
  buildPhase = "tauriBuildHook";
  installPhase = "tauriInstallHook";

  preBuild = ''
    # Tauri expects the frontend build output in distDir specified in tauri.conf.json.
    # We will copy the frontend output to the parent directory since tauri.conf.json says "../dist"
    mkdir -p ../dist
    cp -r ${frontend}/lib/node_modules/omnimux/dist/* ../dist/ || cp -r ${frontend}/dist/* ../dist/ || echo "Warning: Frontend copy failed"
  '';

  passthru = {
    inherit frontend;
  };

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/bin
    ln -s $out/Applications/omnimux.app/Contents/MacOS/omnimux $out/bin/omnimux
  '';

  meta = with lib; {
    description = "OmniMux - A multi-tab terminal GUI for tmux across hosts";
    homepage = "";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "omnimux";
  };
}
