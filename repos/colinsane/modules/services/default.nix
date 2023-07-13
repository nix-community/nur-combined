{ ... }:
{
  imports = [
    ./dyn-dns.nix
    ./kiwix-serve.nix
    ./mautrix-signal.nix
    ./nixserve.nix
    # XXX: partially lifted into nixpkgs repo: remove once upstreamed
    # ./trust-dns.nix
  ];
}
