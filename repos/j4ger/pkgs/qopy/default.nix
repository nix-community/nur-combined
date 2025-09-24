{
  lib,
  stdenv,
  rustPlatform,
  cargo-tauri,
  glib-networking,
  nodejs,
  bun,
  pnpm,
  openssl,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook4,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "qopy";
  version = "0.3.3";
  src = fetchFromGitHub {
    owner = "0PandaDEV";
    repo = "Qopy";
    tag = "v${version}";
    hash = "sha256-aIVLhkBYWbXJYDH01Le8OmwTloV5UwV7IZCdSBBwVYk=";
  };

  cargoHash = "sha256-w72Af94KnL9NsOnjnhefdzvsh6pJ+Xq4HJG40sqB4M8=";
  useFetchCargoVendor = true;

  npmDeps = stdenv.mkDerivation {
    pname = "qopy-npm-deps";
    inherit src version;
    nativeBuildInputs = [ bun ];
    dontConfigure = true;
    buildPhase = ''
    bun install --no-progress --ignore-scripts
    '';
    dontFixup = true;
    installPhase = ''
    mkdir -p $out/node_modules

    cp -R ./node_modules $out
    '';
    outputHash = "sha256-xYx//Ymy8F/rkRcKOnvMtlOgrs6M/fIGJmZvNI3Wg1s=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  nativeBuildInputs = [
    cargo-tauri.hook

    nodejs
    pnpm

    pkg-config
    wrapGAppsHook4
  ];

  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      glib-networking
      webkitgtk_4_1
    ];

  # Set our Tauri source directory
  cargoRoot = "src-tauri";
  # And make sure we build there too
  buildAndTestSubdir = cargoRoot;
}
