{
  lib,
  stdenv,
  rustPlatform,
  buildNpmPackage,
  pkg-config,
  cargo,
  rustc,
  webkitgtk_4_1,
  glib,
  darwin,
  openssl,
  apple-sdk,
}:

let
  frontend = buildNpmPackage {
    pname = "omnimux-ui";
    version = "0.1.0";
    src = ./src;
    npmDepsHash = "sha256-UoYIjFx35LIr/oPKrbZQFgvr2la5SRdHYQNdXIR2Heg=";
  };
in
rustPlatform.buildRustPackage {
  pname = "omnimux";
  version = "0.1.0";

  src = ./src/src-tauri;

  cargoLock = {
    lockFile = ./src/src-tauri/Cargo.lock;
    # allowBuiltinFetchGit = true;
  };

  nativeBuildInputs = [
    pkg-config
    cargo
    rustc
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    webkitgtk_4_1
    glib
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk
  ];

  preBuild = ''
    # Tauri expects the frontend build output in distDir specified in tauri.conf.json.
    # We will copy the frontend output to the parent directory since tauri.conf.json says "../dist"
    mkdir -p ../dist
    cp -r ${frontend}/lib/node_modules/omnimux/dist/* ../dist/ || cp -r ${frontend}/dist/* ../dist/ || echo "Warning: Frontend copy failed"
  '';

  passthru = {
    inherit frontend;
  };

  meta = with lib; {
    description = "OmniMux - A multi-tab terminal GUI for tmux across hosts";
    homepage = "";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
