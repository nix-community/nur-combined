{ ... }:
{
  imports = [
    ./dyn-dns.nix
    ./kiwix-serve.nix
    ./mautrix-signal.nix
    ./nixserve.nix
    ./trust-dns.nix
  ];
}
