# cf

[Cloudflare's CLI](https://github.com/cloudflare/cf), built from its open-beta
source release with the caller's Node.js 24 and pnpm 12. Supports
x86_64-linux, aarch64-linux and aarch64-darwin. Provides both `cf` and
`cloudflare`. Licensed under MIT OR Apache-2.0.

## Usage

```sh
nix build -f . cf
./result/bin/cf --help
./result/bin/cf cli search "list zones"
```

Project-local installations take precedence through upstream's delegation
mechanism. Keep API credentials in runtime environment variables or the CLI's
user configuration, not in Nix expressions. Upstream telemetry can be disabled
with `DO_NOT_TRACK=1` or `CF_SEND_TELEMETRY=false`.

## Maintenance and tests

```sh
nix-shell --run 'just update cf'
nix-shell --run 'just check cf'
```

The update script selects `cf@` GitHub releases, including beta versions, and
refreshes the source and all-platform pnpm dependency hashes. Review the root
and CLI `package.json`, `pnpm-workspace.yaml`, `pnpm-lock.yaml`, CLI build
configuration, configuration loader, authentication and telemetry behavior
when updating. The build uses the release's committed generated commands and
SDK without refetching the OpenAPI schema. It preserves upstream's dependency
patches and bundles the locked workerd runtime, with Linux dynamic-linker paths
repaired for Nix.

Packaging checks cover both executable names, version and help output,
generated command search, runtime dependency imports and an isolated local
Miniflare worker. They do not use credentials or existing services. Only the
current platform is build-tested; upstream unit suites and live Cloudflare API
calls are not run.
