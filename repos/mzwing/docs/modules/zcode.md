# zcode Home Manager module

This module configures [ZCode](https://zcode.z.ai), Z.ai's agentic coding desktop app. It installs the package when `package` is set, links `~/.zcode/AGENTS.md` from `context`, and merges `settings` (plus `programs.mcp.servers` when `enableMcpIntegration` is on) into `~/.zcode/cli/config.json`. The desktop app and its agent CLI both read these files.

## Usage

```nix
# home.nix
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nur.repos.mzwing.modules.homeManager.zcode
  ];

  programs.zcode = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.zcode;

    context = ''
      Prefer concise diffs and run existing tests before finishing.
    '';

    enableMcpIntegration = true;

    settings = {
      permission.mode = "auto";
    };
  };
}
```

When consuming this repository directly as a flake input, import `inputs.mzwing.homeModules.zcode` instead.

## Options

| Option | Default | Description |
| --- | --- | --- |
| `enable` | `false` | Enable ZCode configuration management and install `package` when set. |
| `package` | `null` | Package to install. ZCode is not in nixpkgs; on Linux use e.g. `inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.zcode` from `numtide/llm-agents.nix`, and on macOS install the Homebrew cask `zcode`. |
| `context` | `""` | Global instructions linked to `~/.zcode/AGENTS.md`. Empty means no file is generated. |
| `settings` | `{}` | Settings merged into `~/.zcode/cli/config.json` on each activation. See the [upstream config reference](https://github.com/zai-org/ZCode/blob/main/apps/zcode-cli/docs/usage/03-config.md) for the schema. |
| `enableMcpIntegration` | `false` | Merge `programs.mcp.servers` into `programs.zcode.settings.mcp.servers`. `settings` wins on conflict. |

## Caveats

- **`config.json` is merged, not symlinked.** `~/.zcode/cli/config.json` stays a regular writable file because ZCode rewrites it on every launch (for plugin migrations), on plugin installs, and on skill toggles. Each activation merges the Nix keys in: Nix-owned keys win, keys ZCode wrote are kept, and a key removed from `settings` is removed from the file. Managed paths are tracked in `~/.zcode/cli/.nix-managed.json`, and the first run backs up an existing file to `config.json.stateful`. Editing a Nix-owned key in the app works until the next switch, which puts the Nix value back.
- **`AGENTS.md` is a Nix store symlink.** Saving instructions on the app's personalization page replaces the symlink with a regular file. As usual with Home Manager when a managed link is replaced by a regular file, the next switch fails rather than clobbering it until you remove the file.
- **Skills are not managed here.** ZCode reads `~/.agents/skills` and follows symlinks, so any module that links skills there (such as `agent-skills` targets) already works.
- **Model providers are not managed.** Sign in with a Z.ai or BigModel account in the app. Custom provider API keys live in plaintext in `~/.zcode/v2/provider_config.json`, which must never come from the Nix store.
