---
invokable: true
---

Review this NixOS configuration code for potential issues, including:

- **Nix syntax and best practices**: Check for deprecated patterns, improper use of `mkIf`/`mkMerge`, or missing type annotations.
- **Module structure**: Ensure modules follow the standard pattern (`default.nix` for NixOS, `home.nix` for Home Manager, `package.nix` for packages).
- **Security**: Verify that secrets are properly encrypted with SOPS and not hardcoded in plain text.
- **Dependency management**: Check flake inputs for outdated versions or missing `follows` directives.
- **Performance**: Look for inefficient attribute lookups or unnecessary package rebuilds.
- **Consistency**: Ensure naming conventions are consistent across modules and configurations.
- **Home Manager integration**: Verify that user configurations properly use Home Manager options and don't leak into system configuration.

Provide specific, actionable feedback for improvements.
