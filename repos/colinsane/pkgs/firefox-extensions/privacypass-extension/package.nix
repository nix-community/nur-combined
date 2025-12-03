# N.B.: this package relies on a rust-based library,
# ordinarily built via git submodule + cargo invocation.
# TODO: build that library using Nix; otherwise, it fails to build with raw cargo
# due to a missing cargo vendor pack.
{
  cargo,
  fetchFromGitHub,
  gitUpdater,
  jq,
  rustPlatform,
  stdenv,
  wasm-pack,
  wrapFirefoxAddonsHook,
  zip,
}:
let
  version = "1.0.5";
  src = fetchFromGitHub {
    owner = "kagisearch";
    repo = "privacypass-extension";
    fetchSubmodules = true;
    rev = "v${version}";
    hash = "sha256-FtXX88WUWJ7AYnECsrEJB6+RqhvO3IxdYLS25f79yGc=";
  };
  privacypass-lib = rustPlatform.buildRustPackage {
    pname = "privacypass-lib";
    inherit src version;
    srcRoot = "privacypass-lib";

    # cargoHash = "";  # TODO: upstream doesn't provide a `Cargo.lock` file!
    # postBuild = TODO (wasm-pack)
    # meta = TODO
  };
in
stdenv.mkDerivation {
  pname = "privacypass-extension";
  inherit src version;

  nativeBuildInputs = [
    cargo
    jq
    wasm-pack
    wrapFirefoxAddonsHook
    zip
  ];

  buildPhase = ''
    runHook preBuild

    # upstream method: let it run `cargo build` here, but requires network access to fetch deps.
    # sh ./make.sh

    cp -R ${privacypass-lib}/src/wasm/pkg src/scripts/kagippjs
    # truthy DEBUG_BUILD enables `popup/debug.js` in the runtime
    ./firefox.sh ''${DEBUG_BUILD:-1}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    install build/firefox/kagi_privacypass_firefox_1.0.5.xpi $out/$extid.xpi

    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck

    # make sure we packaged all the resources needed at runtime
    # from manifest.json's `resources` field:
    test -f scripts/kagippjs/kagippjs.js
    test -f scripts/kagippjs/kagippjs_bg.wasm

    runHook postCheck
  '';

  doCheck = true;

  extid = "privacypass@kagi.com";

  passthru = {
    inherit privacypass-lib;
    updateScript = gitUpdater {};
  };
}
