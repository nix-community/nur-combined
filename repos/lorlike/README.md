# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/lorlike/NUR/actions/workflows/build.yml/badge.svg)

## Packages

| Attribute | Description |
| --- | --- |
| `arcana-world` | TUI alternative to bilibili LiveHime, with a TTS helper (`passthru.tui` builds the TUI only) |
| `pigma` | NetEase Cloud Music / local audio playback TUI client |
| `sqlmux` | tmux-like TUI database client for PostgreSQL, MySQL, SQLite, SQL Server and Redis |

## Usage

Via the [NUR](https://github.com/nix-community/NUR) flake input:

```nix
{
  inputs.nur.url = "github:nix-community/NUR";

  # then, for example
  environment.systemPackages = [ inputs.nur.packages.${system}.repos.lorlike.sqlmux ];
}
```

Or apply the overlay directly:

```nix
let
  nur = builtins.fetchTarball "https://github.com/lorlike/NUR/archive/main.tar.gz";
in {
  nixpkgs.overlays = [ (import "${nur}/overlay.nix") ];
  # packages are now available as pkgs.pigma, pkgs.sqlmux, ...
}
```
