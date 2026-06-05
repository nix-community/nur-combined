{ ... }:
{
  imports = [
    ./dropbear.nix
    ./clightning.nix
    ./dyn-dns.nix
    ./eg25-manager.nix
    ./hickory-dns
    ./llama-cpp.nix
    ./ollama.nix
  ];
}
