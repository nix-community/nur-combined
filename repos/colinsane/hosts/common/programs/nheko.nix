{ ... }:
{
  # not strictly necessary, but allows caching articles; offline use, etc.
  sane.programs.nheko.persist.private = [
    ".config/nheko"  # config file (including client token)
    ".cache/nheko"  # media cache
    ".local/share/nheko"  # per-account state database
  ];
}
