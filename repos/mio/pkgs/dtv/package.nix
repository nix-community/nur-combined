{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  nodejs,
  pnpm_9,
  fetchPnpmDeps,
  pnpmConfigHook,
  pkg-config,
  wrapGAppsHook4,
  webkitgtk_4_1,
  glib-networking,
  openssl,
  libsoup_3,
  cargo,
  cacert,
}:

rustPlatform.buildRustPackage rec {
  pname = "dtv";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "chen-zeong";
    repo = "DTV";
    rev = "v${version}";
    sha256 = "0n3bmr3phpbnzib71llxgcw75b4vkliq9h7nidzpz19p0s9k3wgl";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    hash = "sha256-KZfsoKbThbBFasv7sntf2lV4+6hUiSxJTqS2CIG+Bpg=";
    fetcherVersion = 3;
  };

  buildAndTestSubdir = "src-tauri";

  cargoDeps = stdenv.mkDerivation {
    name = "dtv-vendor";
    inherit src;
    nativeBuildInputs = [ rustPlatform.cargoSetupHook cargo cacert ];
    buildPhase = ''
      export CARGO_HOME=$(mktemp -d)
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      export CARGO_HTTP_USER_AGENT="nixpkgs"
      cd src-tauri
      cp ${./Cargo.lock} Cargo.lock
      cargo vendor $out
    '';
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-A7jALEiPqz2qtZg8RM8y5zx21f2YNKDMZBfu5aETbos=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pnpmConfigHook
    pnpm_9

    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    openssl
    webkitgtk_4_1
    libsoup_3
    glib-networking
  ];

  meta = {
    description = "DTV";
    homepage = "https://github.com/chen-zeong/DTV";
    license = lib.licenses.mit;
    mainProgram = "dtv";
    platforms = lib.platforms.linux;
  };
}
