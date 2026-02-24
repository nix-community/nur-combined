{ pkgs, ... }:

{
  environment.systemPackages = [
    # pkgs.nodejs
    pkgs.deno
    # pkgs.bun
    pkgs.typescript
    # pkgs.typescript-language-server
    # pkgs.svelte-language-server
  ];
}
