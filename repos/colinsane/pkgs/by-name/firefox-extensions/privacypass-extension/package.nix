# N.B.: this package relies on a rust-based library,
# ordinarily built via git submodule + cargo invocation,
# and none of the Cargo deps are pinned.
{
  cargo,
  fetchFromGitHub,
  nix-update-script,
  jq,
  rustPlatform,
  wasm-pack,
  wrapFirefoxAddonsHook,
  zip,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "privacypass-extension";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "kagisearch";
    repo = "privacypass-extension";
    fetchSubmodules = true;
    rev = "v${finalAttrs.version}";
    hash = "sha256-5YxcYp0hx90AqhTKURGTDPHJYvGu5UulJ/TKKXv9oTg=";
  };

  cargoRoot = "privacypass-lib/src";
  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "privacypass-0.2.0-pre.0" = "sha256-OpJkfhJ+Zjxd3uoVe+N3cNOA7e1aOkNcf0SIrhAGiiM=";
    };
  };

  postPatch = ''
    cp ${./Cargo.lock} privacypass-lib/src/Cargo.lock
    chmod +x firefox.sh
    patchShebangs --build firefox.sh
  '';

  nativeBuildInputs = [
    cargo
    jq
    wasm-pack
    wrapFirefoxAddonsHook
    zip
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p build/firefox

    # vvv upstream method: let it run `cargo build` here, but requires network access to fetch deps.
    # sh ./make.sh
    # cp -R privacypass-lib/src/wasm/pkg src/scripts/kagippjs
    # truthy DEBUG_BUILD enables `popup/debug.js` in the runtime
    # ./firefox.sh ''${DEBUG_BUILD:-1}
    # ^^^

    # vvv inlined from `make.sh`, but with git operations removed
      (cd privacypass-lib/src; bash build.sh)

      rm -rf src/scripts/kagippjs
      cp -r privacypass-lib/src/wasm/pkg src/scripts/kagippjs

      # BUILDDIR=build/chrome bash chrome.sh $DEBUG
      BUILDDIR=build/firefox bash firefox.sh $DEBUG
    # ^^^

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

  meta.broken = true;  # XXX(2026-02-23): blind-rsa-signatures dependency fails build. this is why you use lockfiles.

  passthru = {
    updateWithSuper = false;  # no way to validate any update, since the deps are broken (no lockfile).
    updateScript = nix-update-script {
      extraArgs = [
        "--generate-lockfile"
        "--lockfile-metadata-path"
        "privacypass-lib/src"
      ];
    };
  };
})
