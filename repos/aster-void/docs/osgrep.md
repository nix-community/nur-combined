# osgrep (Home Manager)

A HM module that installs osgrep and optionally integrates it with Claude Code.
This assumes it has already been installed: see <./installation.md>

If you don't need the Claude Code integration, you can instead just install it to system packages.

## Usage

```nix
{ inputs, pkgs, ... }:
{
  # Import the module
  imports = [
    inputs.nix-repository.homeModules.osgrep
  ];

  # Enable osgrep
  programs.osgrep.enable = true;
}
```

## Options

```nix
{
  # Enable the module
  # type: bool
  programs.osgrep.enable = true;

  # Which osgrep package to install
  # type: package
  # default: this repo's osgrep
  # programs.osgrep.package = inputs.nix-repository.packages.${pkgs.system}.osgrep;

  # Install osgrep Claude Code plugin via `osgrep install-claude-code`
  # This adds the osgrep marketplace and installs the plugin with hooks
  # that automatically start/stop `osgrep serve` during Claude Code sessions
  # type: bool
  # default: true
  # programs.osgrep.enableClaudeCodeIntegration = false;
}
```
