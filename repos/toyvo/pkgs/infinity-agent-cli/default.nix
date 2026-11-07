# infinity-agent-cli + infinity-provider-bedrock: terminal client and model
# provider for Infinity coding agents (https://github.com/hydro-project/infinity,
# docs: https://infinity.hydro.run/docs/infinity-code/overview/).
#
# Both are built from the same repo checkout (per-crate tags like
# infinity-agent-cli-v0.2.0 point at whole-repo commits), so they share
# versions.json and a single update.ts. Only the CLI needs the
# `bundled-web` feature; the provider is a plain cargo build.
#
# NOTE: rev is pinned past the v0.2.0 tag to 1abc6fc (upstream #176),
# which enables the aws-config `sso` feature so SSO profiles (sso_session)
# can resolve credentials; without it every Bedrock request fails with an
# SSO dispatch failure. update.ts keeps the pin until upstream cuts a new
# infinity-agent-cli-v* release containing the fix.
#
# bundled-web makes infinity-daemon's build.rs run `npm ci` (infinity-ui
# and infinity-web) plus `npm run build` (infinity-web) at compile time.
# Those npm steps run fully offline against two prefetched npm caches
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
  makeWrapper,
  bubblewrap,
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
  common = {
    inherit (versions) version;
    inherit src;
    cargoHash = versions.cargoHash;
    nativeBuildInputs = [ pkg-config ];
    # On Darwin the default SDK sysroot resolves `-framework Security`
    # (native-tls) with no extra inputs; openssl/pkg-config are for Linux.
    buildInputs = [ openssl ];
    # Upstream tests spin up local daemon/test servers and browser e2e
    # (playwright); unsuitable for the sandbox.
    doCheck = false;
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
  # infinity-provider-models-dev lives in a separate repo (ToyVo fork),
  # so it has its own source and vendor hash, tracked under
  # versions.json: modelsDev.
  modelsDevSrc = fetchFromGitHub {
    owner = "ToyVo";
    repo = "infinity-provider-models-dev";
    rev = versions.modelsDev.rev;
    hash = versions.modelsDev.hash;
  };
in
{
  infinity-agent-cli = rustPlatform.buildRustPackage (
    common
    // {
      pname = "infinity-agent-cli";
      nativeBuildInputs = common.nativeBuildInputs ++ [ nodejs ];

      # Only the CLI crate (and its path deps), not the whole workspace's
      # bins. `--features` needs the `-p` selection in a virtual workspace.
      cargoBuildFlags = [
        "-p"
        "infinity-agent-cli"
      ];
      buildFeatures = [ "bundled-web" ];

      # npm (invoked by infinity-daemon's build.rs) must run offline against
      # the prefetched caches: the sandbox has no network on Linux, and the
      # store source tree is read-only, so merge both caches into a writable
      # tmp dir. npm's cache is content-addressed, so merging ui+web is safe.
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

        # Upstream build.rs shells out to bare `npm`, and the .bin shims
        # `npm ci` installs carry `#!/usr/bin/env node` shebangs, which
        # don't resolve in the Linux sandbox (no /usr/bin/env; Darwin
        # has one, which is why local mac builds pass). Wrap npm so every
        # invocation re-points freshly installed shims at the store node.
        mkdir -p "$TMPDIR/npm-bin"
        cat > "$TMPDIR/npm-bin/npm" <<'EOF'
        #!${stdenv.shell}
        patch_shims() {
          prefix=""
          prev=""
          for arg in "$@"; do
            case "$arg" in
              --prefix=*) prefix=$(echo "$arg" | sed 's/^--prefix=//') ;;
              *)
                if [ "$prev" = "--prefix" ]; then prefix="$arg"; fi
                prev="$arg"
                ;;
            esac
          done
          if [ -n "$prefix" ]; then
            case "$prefix" in
              /*) root="$prefix" ;;
              *) root="$PWD/$prefix" ;;
            esac
            if [ -d "$root/node_modules" ]; then
              find "$root/node_modules" -type d -name .bin | while IFS= read -r bindir; do
                for link in "$bindir"/*; do
                  [ -e "$link" ] || continue
                  target=$(readlink -f "$link")
                  if [ -f "$target" ] && [ "$(head -n 1 "$target")" = "#!/usr/bin/env node" ]; then
                    sed -i '1s|^#!/usr/bin/env node|#!${nodejs}/bin/node|' "$target"
                  fi
                done
              done
            fi
          fi
        }
        patch_shims "$@"
        ${nodejs}/bin/npm "$@"
        status=$?
        patch_shims "$@"
        exit $status
        EOF
        chmod +x "$TMPDIR/npm-bin/npm"
        export PATH="$TMPDIR/npm-bin:$PATH"
      '';

      # The binary gets a --version install check instead of the test suite.
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
  );

  infinity-provider-bedrock = rustPlatform.buildRustPackage (
    common
    // {
      pname = "infinity-provider-bedrock";
      cargoBuildFlags = [
        "-p"
        "infinity-provider-bedrock"
      ];
      doInstallCheck = false;

      meta = {
        description = "Native AWS Bedrock model provider for Infinity coding agents";
        homepage = "https://github.com/hydro-project/infinity";
        license = lib.licenses.asl20;
        maintainers = with lib.maintainers; [ toyvo ];
        mainProgram = "infinity-provider-bedrock";
        platforms = lib.platforms.unix;
      };
    }
  );

  infinity-provider-models-dev = rustPlatform.buildRustPackage (
    common
    // {
      pname = "infinity-provider-models-dev";
      version = versions.modelsDev.version;
      src = modelsDevSrc;
      cargoHash = versions.modelsDev.cargoHash;
      cargoBuildFlags = [
        "-p"
        "infinity-provider-models-dev"
      ];
      doInstallCheck = false;

      meta = {
        description = "Multi provider for Infinity coding agents";
        homepage = "https://github.com/ToyVo/infinity-provider-models-dev";
        license = lib.licenses.asl20;
        maintainers = with lib.maintainers; [ toyvo ];
        mainProgram = "infinity-provider-models-dev";
        platforms = lib.platforms.unix;
      };
    }
  );

  sandbox-local = rustPlatform.buildRustPackage (
    common
    // {
      pname = "sandbox-local";
      cargoBuildFlags = [
        "-p"
        "sandbox-local"
      ];
      # crates/sandbox-local/build.rs probes `bwrap --version` and, when
      # absent, falls back to install-bwrap.sh, which `git clone`s bubblewrap
      # from the network (no git/network in the Linux sandbox -> exit 127).
      # Providing bubblewrap satisfies the probe so the fallback never runs.
      # Non-Linux builds skip this: build.rs returns early off Linux, and
      # bubblewrap is Linux-only, so the inputs stay empty there.
      nativeBuildInputs =
        common.nativeBuildInputs
        ++ lib.optionals stdenv.isLinux [
          bubblewrap
          makeWrapper
        ];
      # The server shells out to `bwrap` at runtime (wired as an MCP
      # toolset command in modules/home/programs/infinity.nix), so keep it
      # on PATH next to the binary instead of relying on the host system.
      postFixup = lib.optionalString stdenv.isLinux ''
        wrapProgram $out/bin/sandbox-local \
          --prefix PATH : "${lib.makeBinPath [ bubblewrap ]}"
      '';
      doInstallCheck = false;

      meta = {
        description = "Local sandbox RAP server for Infinity coding agents.";
        homepage = "https://github.com/hydro-project/infinity";
        license = lib.licenses.asl20;
        maintainers = with lib.maintainers; [ toyvo ];
        mainProgram = "sandbox-local";
        platforms = lib.platforms.unix;
      };
    }
  );

  rap-steering-server = rustPlatform.buildRustPackage (
    common
    // {
      pname = "rap-steering-server";
      cargoBuildFlags = [
        "-p"
        "rap-steering-server"
      ];
      doInstallCheck = false;

      meta = {
        description = "RAP tool server exposing project steering files to Infinity agents.";
        homepage = "https://github.com/hydro-project/infinity";
        license = lib.licenses.asl20;
        maintainers = with lib.maintainers; [ toyvo ];
        mainProgram = "rap-steering-server";
        platforms = lib.platforms.unix;
      };
    }
  );

  rap-github-event-poller = rustPlatform.buildRustPackage (
    common
    // {
      pname = "rap-github-event-poller";
      cargoBuildFlags = [
        "-p"
        "rap-github-event-poller"
      ];
      doInstallCheck = false;

      meta = {
        description = "RAP tool server that polls GitHub and delivers repository events to Infinity agents as subscriptions.";
        homepage = "https://github.com/hydro-project/infinity";
        license = lib.licenses.asl20;
        maintainers = with lib.maintainers; [ toyvo ];
        mainProgram = "rap-github-event-poller";
        platforms = lib.platforms.unix;
      };
    }
  );
}
