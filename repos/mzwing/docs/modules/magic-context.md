# magic-context Home Manager module

This module installs [Magic Context](https://github.com/cortexkit/magic-context) — self-managing context and cross-session memory for coding agents — and renders its configuration declaratively. It works the same on NixOS and nix-darwin.

Magic Context reads one shared configuration file, `~/.config/cortexkit/magic-context.jsonc`, regardless of which harness loads the plugin. That file is what this module owns.

Registering the plugin with a harness is **not** part of the module: run `magic-context setup` (optionally `--harness opencode`, `--harness pi` or `--harness omp`) once, and the harness installs and loads the plugin from npm itself. Setup skips writing the configuration file that already exists here.

## Usage

```nix
# home.nix
{
  inputs,
  ...
}: {
  imports = [
    inputs.nur.repos.mzwing.modules.homeManager.magic-context
  ];

  programs.magic-context = {
    enable = true;

    settings = {
      # Required for history compacting; use historian.pi.model for Pi and OMP.
      historian.opencode.model = "anthropic/claude-sonnet-4-6";
      # Optional: overnight memory consolidation and /ctx-aug.
      dreamer.opencode.model = "anthropic/claude-haiku-4-5";
      sidekick.opencode.model = "anthropic/claude-haiku-4-5";
    };
  };
}
```

When consuming this repository directly as a flake input, import `inputs.mzwing.homeModules.magic-context` instead.

## Options

| Option | Default | Description |
| --- | --- | --- |
| `enable` | `false` | Install the CLI into `home.packages` and manage the configuration file. |
| `package` | `inputs.nur.repos.mzwing.magic-context` | The `magic-context` CLI package. |
| `settings` | `{}` | Freeform attrset rendered to `~/.config/cortexkit/magic-context.jsonc`. Empty means no file is generated. |

## Caveats

- **The config file is read-only.** `~/.config/cortexkit/magic-context.jsonc` is a Nix store symlink, so the desktop app's config editor and `magic-context setup` cannot write it. Change `programs.magic-context.settings` instead. This is the same trade-off as `programs.gryph.settings`.
- **A historian model is required.** Without `historian.opencode.model` (or `historian.pi.model`) the plugin loads but every historian run fails; the module warns at switch time.
- **Project overrides still work.** A repository's `.cortexkit/magic-context.jsonc` merges on top of this file, and it is a normal writable file.
- **State is not Nix-managed.** The database at `~/.local/share/cortexkit/magic-context/context.db` **must persist** — losing it loses your memory and history. The ~90 MB `Xenova/all-MiniLM-L6-v2` model cache is downloaded next to it on first use, unless you disable memory or point `embedding` at a remote backend.
- **Local embeddings may be unavailable on NixOS.** They come from `onnxruntime-node`, a prebuilt native module the harness installs from npm and loads with `dlopen`; unpatched ELF binaries frequently fail to resolve `libstdc++.so.6` there. Magic Context latches that failure and degrades cleanly, so context management and keyword search keep working while semantic search does not. Point `embedding` at an `openai_compatible` or `ollama` backend if you hit it.
