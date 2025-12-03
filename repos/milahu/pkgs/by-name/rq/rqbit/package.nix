{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  buildNpmPackage,
  nodejs_20,
  nix-update-script,
}:

# librqbit-core@5.0.0 requires rustc 1.88
let
  # https://github.com/oxalica/rust-overlay/issues/209
  rust-overlay-src = fetchFromGitHub {
    owner = "oxalica";
    repo = "rust-overlay";
    rev = "971d18658c83f3a6a434ac647798141fddce3175";
    hash = "sha256-LTgfljA/X8aGEXk/EUVoLL+0wfJjQAhF/rUQOFsx+/U=";
  };
  # re-evaluate pkgs
  pkgsWithOverlay = import <nixpkgs> {
    overlays = [ (import rust-overlay-src) ];
  };
in
with pkgsWithOverlay;
let
  rustSpecific = rust-bin.stable.latest.default;
  # rustSpecific = (rustChannelOf { channel = "1.90.0"; }).rust;
  rustPlatform = makeRustPlatform {
    cargo = rustSpecific;
    rustc = rustSpecific;
  };
in

let
  pname = "rqbit";

  version = "9.0.0-beta.1-b1a3074";

  src = fetchFromGitHub {
    owner = "ikatson";
    repo = "rqbit";
    # rev = "v${version}";
    # https://github.com/ikatson/rqbit/pull/489
    rev = "b1a3074440175a0b13052aac9570627f29c0d377";
    hash = "sha256-Xv8S/EFFRx4HESUNV6CGshSby4UJGAFYmA7QMmXVV1w=";
  };

  rqbit-webui = buildNpmPackage {
    pname = "rqbit-webui";

    nodejs = nodejs_20;

    inherit version src;

    sourceRoot = "${src.name}/crates/librqbit/webui";

    npmDepsHash = "sha256-w75czvBzwVRNVXftVwJxWYTaCztXAKcfALc7Kve70fs=";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/dist
      cp -r dist/** $out/dist

      runHook postInstall
    '';
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-5pY7YqQle0p8GUtOOfrymf052EF3WoW/8lyO2X3nhoM=";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ pkg-config ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ openssl ];

  preConfigure = ''
    mkdir -p crates/librqbit/webui/dist
    cp -R ${rqbit-webui}/dist/** crates/librqbit/webui/dist
  '';

  postPatch = ''
    # This script fascilitates the build of the webui,
    #  we've already built that
    rm crates/librqbit/build.rs
  '';

  doCheck = false;

  passthru.webui = rqbit-webui;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--subpackage"
      "webui"
    ];
  };

  meta = {
    description = "Bittorrent client in Rust";
    homepage = "https://github.com/ikatson/rqbit";
    changelog = "https://github.com/ikatson/rqbit/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      cafkafk
      toasteruwu
    ];
    mainProgram = "rqbit";
  };
}
