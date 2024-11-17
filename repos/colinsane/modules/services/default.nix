{ ... }:
{
  imports = [
    # ./bonsaid.nix  #< UPSTREAMING IN PROGRESS: <https://github.com/NixOS/nixpkgs/pull/347818>
    ./buffyboard.nix
    ./dropbear.nix
    ./clightning.nix
    ./dyn-dns.nix
    ./eg25-manager.nix
    ./hickory-dns
    ./kiwix-serve.nix
    ./ollama.nix
  ];
}
