{ ... }:
{
  imports = [
    ./dropbear.nix
    ./clightning.nix
    ./dyn-dns.nix
    ./eg25-manager.nix
    ./hickory-dns
    ./kiwix-serve.nix
    ./ollama.nix
  ];
}
