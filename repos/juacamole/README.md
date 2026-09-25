# nur-packages

My [NUR](https://github.com/nix-community/NUR) repository.

## Packages

### `tapioca`

[Tapioca](https://github.com/juacamole/tapioca) — an agentic coding TUI for
local and hosted LLMs. Installs two binaries from one build: `tapioca`, and
`tapio` for when Shopify's `tapioca` gem wins `PATH`.

## Usage

Add NUR to your configuration — see [the NUR
README](https://github.com/nix-community/NUR#installation) — then:

```nix
environment.systemPackages = [ pkgs.nur.repos.juacamole.tapioca ];
```

Or try it without installing anything:

```console
$ nix-shell -p 'let nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") { inherit pkgs; }; in nur.repos.juacamole.tapioca'
```

Straight from the source repository, without NUR:

```console
$ nix run github:juacamole/tapioca
```

## Building locally

```console
$ nix-build -A tapioca
```
