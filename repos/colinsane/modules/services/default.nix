{ ... }:
{
  imports = [
    ./dropbear.nix
    ./clightning.nix
    ./dyn-dns.nix
    ./eg25-manager.nix
    ./kiwix-serve.nix
    ./trust-dns
  ];
}
