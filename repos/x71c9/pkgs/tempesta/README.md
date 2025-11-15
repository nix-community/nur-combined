# tempesta

The fastest and lightest bookmark manager CLI written in Rust.

## Installation

```nix
# Basic installation
environment.systemPackages = [ nur.repos.x71c9.tempesta ];

# Or in home-manager
home.packages = [ nur.repos.x71c9.tempesta ];
```

## Shell Completion Support

This package supports configurable shell completions for bash, zsh, and fish.

### Default (bash completion enabled)
```nix
nur.repos.x71c9.tempesta
```

### Disable completions
```nix
nur.repos.x71c9.tempesta.override {
  completion.enable = false;
}
```

### Multiple shells
```nix
nur.repos.x71c9.tempesta.override {
  completion = {
    enable = true;
    shells = [ "bash" "zsh" "fish" ];  # Install for all supported shells
  };
}
```

### Specific shell only
```nix
nur.repos.x71c9.tempesta.override {
  completion = {
    enable = true;
    shells = [ "zsh" ];  # Only zsh completion
  };
}
```

## NixOS Integration

To enable shell completion system-wide, ensure you have:

```nix
# For bash users
programs.bash.enableCompletion = true;

# For zsh users  
programs.zsh.enableCompletion = true;

# For fish users
programs.fish.enable = true;
```

The completion scripts will be automatically available once the package is installed and your shell completion system is enabled.

## Package Options

- `completion.enable`: Enable/disable shell completion installation (default: `true`)
- `completion.shells`: List of shells to generate completions for (default: `[ "bash" ]`)
  - Supported values: `"bash"`, `"zsh"`, `"fish"`

## Homepage

https://github.com/x71c9/tempesta