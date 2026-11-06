# infinity-agent-cli: terminal client for Infinity coding agents
# (https://github.com/hydro-project/infinity,
# docs: https://infinity.hydro.run/docs/infinity-code/overview/).
#
# Built with the `bundled-web` feature so the desktop web UI works. That
# feature makes infinity-daemon's build.rs run `npm ci` (infinity-ui and
# infinity-web) plus `npm run build` (infinity-web) at compile time. Those
# npm steps run fully offline here against two prefetched npm caches
# (versions.json: npmUiHash/npmWebHash), merged into one writable cache dir
# in preBuild and selected via npm_config_* env (build.rs invokes bare
# `npm`, so env is the only control we have).
{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchNpmDeps,
  nodejs,
  pkg-config,
  openssl,
  versionCheckHook,
  ...
}:
let
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
  src = fetchFromGitHub {
    owner = "hydro-project";
    repo = "infinity";
    rev = versions.rev;
    hash = versions.hash;
  };
  npmUiDeps = fetchNpmDeps {
    name = "infinity-ui-npm-deps";
    src = "${src}/infinity-ui";
    hash = versions.npmUiHash;
  };
  npmWebDeps = fetchNpmDeps {
    name = "infinity-web-npm-deps";
    src = "${src}/infinity-web";
    hash = versions.npmWebHash;
  };
in
rustPlatform.buildRustPackage {
  pname = "infinity-agent-cli";
  inherit (versions) version;
  inherit src;

  cargoHash = versions.cargoHash;

  # Only the CLI crate (and its path deps), not the whole workspace's bins.
  # `--features` needs the `-p` selection in a virtual workspace.
  cargoBuildFlags = [
    "-p"
    "infinity-agent-cli"
  ];
  buildFeatures = [ "bundled-web" ];

  nativeBuildInputs = [
    nodejs
    pkg-config
  ];

  # On Darwin the default SDK sysroot resolves `-framework Security`
  # (native-tls) with no extra inputs; openssl/pkg-config are for Linux.
  buildInputs = [
    openssl
  ];

  # npm (invoked by infinity-daemon's build.rs) must run offline against the
  # prefetched caches: the sandbox has no network on Linux, and the store
  # source tree is read-only, so merge both caches into a writable tmp dir.
  # npm's cache is content-addressed, so merging ui+web is safe.
  preBuild = ''
    npmCacheDir=$(mktemp -d)
    cp -r ${npmUiDeps}/. "$npmCacheDir"/
    chmod -R +w "$npmCacheDir"
    cp -r ${npmWebDeps}/. "$npmCacheDir"/
    chmod -R +w "$npmCacheDir"
    export npm_config_cache="$npmCacheDir"
    export npm_config_offline="true"
    export npm_config_audit="false"
    export npm_config_fund="false"
    export HOME="$TMPDIR"
  '';

  # Upstream tests spin up local daemon/test servers and browser e2e
  # (playwright); unsuitable for the sandbox. The binary gets a --version
  # install check instead.
  doCheck = false;

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  meta = {
    description = "Terminal client for Infinity coding agents";
    homepage = "https://github.com/hydro-project/infinity";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ toyvo ];
    mainProgram = "infinity";
    platforms = lib.platforms.unix;
  };
}
